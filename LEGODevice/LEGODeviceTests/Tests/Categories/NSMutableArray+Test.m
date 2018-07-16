//
// Created by Søren Toft Odgaard on 15/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "NSMutableArray+Test.h"


@implementation NSMutableArray (Test)

- (void)shuffle
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSInteger nElements = count - i;
        NSInteger n = arc4random_uniform((uint32_t)nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

@end