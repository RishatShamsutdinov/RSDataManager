//
//  NSManagedObject+Merging.h
//  RSDataManager
//
//  Created by rishat on 15.04.15.
//
//

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
