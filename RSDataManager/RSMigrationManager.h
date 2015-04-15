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

@protocol RSMigrationManager <NSObject>

/**
 * @return YES if the migration proceeds without errors during the compatibility checks or migration, otherwise NO.
 */
- (BOOL)migrateStoreAtURL:(NSURL *)storeURL ofType:(NSString *)storeType
                  toModel:(NSManagedObjectModel *)finalModel error:(NSError **)error;

@end
