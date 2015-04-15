//
//  NSManagedObject+Merging.m
//  RSDataManager
//
//  Created by rishat on 15.04.15.
//
//

#import "NSManagedObject+Merging.h"

@implementation NSManagedObject (Merging)

- (instancetype)rs_isParentRelationship:(NSRelationshipDescription *)relDesc {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"The method %@ must be overridden",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (instancetype)rs_clone {
    return [self rs_cloneInContext:self.managedObjectContext];
}

- (instancetype)rs_cloneInContext:(NSManagedObjectContext *)context {
    id result = [[NSManagedObject alloc] initWithEntity:self.entity insertIntoManagedObjectContext:context];

    [result rs_mergeWithObject:self];

    return result;
}

- (void)rs_mergeWithObject:(id)object {
    if (object == self) {
        return;
    }

    if (![object isKindOfClass:[self class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:@"Class of object (%@) isn't kind of %@",
                                               NSStringFromClass([object class]), NSStringFromClass([self class])]
                                     userInfo:nil];
    }

    id (^cloneObjectIfNeeded)(id obj) = ^id(id obj) {
        if ([obj isKindOfClass:[NSManagedObject class]]) {
            return [obj rs_cloneInContext:self.managedObjectContext];
        }

        return obj;
    };

    [[self.entity properties] enumerateObjectsUsingBlock:
     ^(NSPropertyDescription *propDesc, NSUInteger idx, BOOL *stop) {
         NSString *name = propDesc.name;
         id value = [object valueForKey:name];
         BOOL deleteOldValueSet = NO;

         if ([propDesc isKindOfClass:[NSRelationshipDescription class]]) {
             NSRelationshipDescription *relDesc = (id)propDesc;

             if ([self rs_isParentRelationship:relDesc]) {
                 // we shouldn't update the parent
                 return;
             }

             deleteOldValueSet = (relDesc.deleteRule == NSCascadeDeleteRule);
         }

         if ([value isKindOfClass:[NSOrderedSet class]]) {
             NSMutableOrderedSet *set = [NSMutableOrderedSet new];

             [(NSOrderedSet *)value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                 [set addObject:cloneObjectIfNeeded(obj)];
             }];

             value = [set copy];
         } else if ([value isKindOfClass:[NSSet class]]) {
             NSMutableSet *set = [NSMutableSet new];

             [(NSSet *)value enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                 [set addObject:cloneObjectIfNeeded(obj)];
             }];

             value = [set copy];
         } else {
             value = cloneObjectIfNeeded(value);
         }

         id oldValue = [self valueForKey:name];

         [self setValue:value forKey:name];

         if (deleteOldValueSet) {
             NSSet *set;

             if ([oldValue isKindOfClass:[NSOrderedSet class]]) {
                 set = [(NSOrderedSet *)oldValue set];
             } else if ([oldValue isKindOfClass:[NSSet class]]) {
                 set = oldValue;
             }

             [set enumerateObjectsUsingBlock:^(NSManagedObject *obj, BOOL *stop) {
                 [obj.managedObjectContext deleteObject:obj];
             }];
         }
     }];
}

@end
