//
// Created by Søren Toft Odgaard on 9/9/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NSArray+LEAdditional.h"


@implementation NSArray (LEAdditional)

- (NSArray *)arrayByRemovingObject:(id)object {
    NSParameterAssert(object != nil);
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:self];
    [mutableArray removeObject:object];
    return [NSArray arrayWithArray:mutableArray];
}

@end