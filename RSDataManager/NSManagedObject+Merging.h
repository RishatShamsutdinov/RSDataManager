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

#import <CoreData/CoreData.h>

@interface NSManagedObject (Merging)

/**
 * Should be overridden if relationships exist in this object
 */
- (instancetype)rs_isParentRelationship:(NSRelationshipDescription *)relDesc;

- (instancetype)rs_clone;
- (instancetype)rs_cloneInContext:(NSManagedObjectContext *)context;

/**
 * @param object's class must be kind of current class
 * @see rs_isParentRelationship:
 */
- (void)rs_mergeWithObject:(id)object;

@end
