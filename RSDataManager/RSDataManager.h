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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RSDataManagerConfiguration.h"

@interface RSDataManager : NSObject

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;

/**
 * Concurrency type is NSPrivateQueueConcurrencyType.
 */
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (instancetype)initWithConfiguration:(id<RSDataManagerConfiguration>)config;

- (id)createEntityWithClassName:(NSString *)className;
- (id)createEntityWithClass:(Class)aClass;

- (void)performBlock:(void (^)())block;
- (void)performBlockAndWait:(void (^)())block;

@end
