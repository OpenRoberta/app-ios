//
// Created by Søren Toft Odgaard on 9/9/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSSet+LEAdditional.h"


@implementation NSSet (LEAdditional)

- (NSSet *)setByRemovingObject:(id)object {
    assert(object);
    NSMutableSet *mutableSet = [NSMutableSet setWithSet:self];
    [mutableSet removeObject:object];
    return [NSSet setWithSet:mutableSet];
}

- (NSArray *)filteredArrayWithKindOfClass:(Class)class sortedByProperty:(NSString *)propertyName ascending:(BOOL)ascending {
    NSSet *filteredSet = [self filteredSetUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", class]];
    return [filteredSet sortedArrayUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:propertyName ascending:ascending]]];
}

@end