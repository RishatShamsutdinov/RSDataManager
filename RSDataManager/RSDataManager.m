/**
 *
 * Copyright 2015 Rishat Shamsutdinov
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "RSDataManager.h"

@implementation RSDataManager

+ (NSManagedObjectModel *)modelFromConfig:(id<RSDataManagerConfiguration>)config {
    NSManagedObjectModel *model;

    if ([config respondsToSelector:@selector(model)]) {
        model = [config model];
    }

    if (!model && [config respondsToSelector:@selector(modelURL)]) {
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[config modelURL]];
    }

    if (!model) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"No managed object model found"
                                     userInfo:nil];
    }

    return model;
}

- (instancetype)initWithConfiguration:(id<RSDataManagerConfiguration>)config {
    if (self = [self init]) {
        [self configureModelWithConfig:config];

        [self configurePersistentStoreCoordinatorWithConfig:config];

        [self configureManagedObjectContext];
    }

    return self;
}

- (void)configureModelWithConfig:(id<RSDataManagerConfiguration>)config {
    NSManagedObjectModel *model;

    if ([config respondsToSelector:@selector(model)]) {
        model = [config model];
    }

    if (!model && [config respondsToSelector:@selector(modelURL)]) {
        model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[config modelURL]];
    }

    if (!model) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"No managed object model found"
                                     userInfo:nil];
    }

    _managedObjectModel = model;
}

- (void)configurePersistentStoreCoordinatorWithConfig:(id<RSDataManagerConfiguration>)config {
    NSURL *storeURL = [config storeURL];
    NSString *storePath = storeURL.absoluteString;

    if ([config respondsToSelector:@selector(defaultStorePath)] && storePath) {
        NSString *defaultStorePath = [config defaultStorePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];

        if (defaultStorePath && ![fileManager fileExistsAtPath:storePath]) {
            [fileManager copyItemAtPath:defaultStorePath toPath:storePath error:NULL];
        }
    }

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:self.managedObjectModel];

    if ([_persistentStoreCoordinator persistentStoreForURL:storeURL]) {
        return;
    }

    NSString *storeType = [config storeType];
    NSString *configName;

    if ([config respondsToSelector:@selector(storeConfigurationName)]) {
        configName = [config storeConfigurationName];
    }

    NSError __block *error;

    BOOL (^tryToAddPersistentStore)() = ^BOOL {
        id store = [_persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:configName
                                                                       URL:storeURL options:[config storeOptions]
                                                                     error:&error];

        return (store != nil);
    };

    switch ([config migrationStrategy]) {
        case RSMigrationStrategyNone:
            tryToAddPersistentStore();
            break;

        case RSMigrationStrategyRemoveStoreOnError: {
            if (!tryToAddPersistentStore()) {
                error = nil;

                if ([[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error]) {
                    tryToAddPersistentStore();
                }
            }

            break;
        }

        case RSMigrationStrategyUseCustomMigrationManager: {
            id<RSMigrationManager> migrationManager = [config migrationManager];

            if ([migrationManager migrateStoreAtURL:storeURL ofType:storeType
                                            toModel:self.managedObjectModel error:&error])
            {
                tryToAddPersistentStore();
            }

            break;
        }
    }

    if (error && [_persistentStoreCoordinator persistentStores].count == 0) {
        NSLog(@"warning: Failed to add persistent store with error: %@", error);
    }
}

- (void)configureManagedObjectContext {
    NSPersistentStoreCoordinator *storeCoordinator = self.persistentStoreCoordinator;

    if (storeCoordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

        _managedObjectContext.persistentStoreCoordinator = storeCoordinator;
    }
}

- (id)createEntityWithClass:(Class)aClass {
    return [self createEntityWithClassName:NSStringFromClass(aClass)];
}

- (id)createEntityWithClassName:(NSString *)className {
    NSEntityDescription *entity = [[self.managedObjectModel entitiesByName] objectForKey:className];

    return [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
}

- (void)performBlockWithManagedObjectContext:(void (^)(NSManagedObjectContext *context))block {
    NSManagedObjectContext *context = self.managedObjectContext;

    if (!context) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"Trying to perform method that using nil managedObjectContext"
                                     userInfo:nil];
    }

    block(context);
}

- (void)performBlock:(void (^)())block {
    [self performBlockWithManagedObjectContext:^(NSManagedObjectContext *context) {
        [context performBlock:block];
    }];
}

- (void)performBlockAndWait:(void (^)())block {
    [self performBlockWithManagedObjectContext:^(NSManagedObjectContext *context) {
        [context performBlockAndWait:block];
    }];
}

@end
