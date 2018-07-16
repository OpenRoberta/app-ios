//
// Created by Søren Toft Odgaard on 01/11/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "NSSet+LEAdditional.h"
#import "LETestCase.h"

@interface NSSetLEAdditionalTest : LETestCase

@end


@implementation NSSetLEAdditionalTest {

}

- (void)testSetByRemovingObject {
    NSSet *aSet = [NSSet setWithArray:@[ @1, @2, @3 ]];

    aSet = [aSet setByRemovingObject:@1];
    XCTAssertFalse([aSet containsObject:@1]);
    XCTAssertTrue([aSet containsObject:@2]);
    XCTAssertTrue([aSet containsObject:@3]);

    //just make sure it does not crash when removing same object again
    [aSet setByRemovingObject:@1];

    aSet = [[aSet setByRemovingObject:@2] setByRemovingObject:@3];
    XCTAssertEqual((int) 0, (int) aSet.count);
}

- (void)testFilteredArrayWithKindOfClass {
    NSSet *aSet = [NSSet setWithArray:@[ @1, @2, @"Hello", @"You" ]];

    BOOL ascending = YES;
    NSArray *result = [aSet filteredArrayWithKindOfClass:[NSString class] sortedByProperty:@"length" ascending:ascending];

    XCTAssertEqual((int) 2, (int) result.count);
    XCTAssertEqual(result[0], @"You");
    XCTAssertEqual(result[1], @"Hello");

    ascending = NO;
    result = [aSet filteredArrayWithKindOfClass:[NSString class] sortedByProperty:@"length" ascending:ascending];
    XCTAssertEqual(result[0], @"Hello");
    XCTAssertEqual(result[1], @"You");
}


@end