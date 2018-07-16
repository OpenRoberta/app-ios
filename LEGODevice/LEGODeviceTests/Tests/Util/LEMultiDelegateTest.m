//
//  LEMultiDelegateTest.m
//  LEGODevice
//
//  Created by Jon Nørrelykke on 02/12/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEMultiDelegate.h"


@interface LEMultiDelegateTest : LETestCase
@property (nonatomic, weak) id weakOne;
@end

@implementation LEMultiDelegateTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testWeak {
    NSObject *strongOne = [[NSObject alloc] init];
    self.weakOne = strongOne; //count 1
    @autoreleasepool {
        
        if (self.weakOne) {
            NSLog(@"weakOne is not nil."); //count 2
        } else {
            NSLog(@"weakOne is nil.");
        }
        
        strongOne = nil; // count 1
        
        if (self.weakOne) {
            NSLog(@"weakOne is not nil.");
        } else {
            NSLog(@"weakOne is nil.");
        }
        
    } // count 0, therefore the weakOne become nil
    
    XCTAssertNil(self.weakOne, @"Should be nil");
    
    if (self.weakOne) {
        NSLog(@"weakOne is not nil.");
    } else {
        NSLog(@"weakOne is nil.");
    }
}


- (void)testWeakReferences
{
    LEMultiDelegate *delegates = [LEMultiDelegate new];
    NSObject *hello = [[NSObject alloc] init];
    [delegates addDelegate:hello];
    @autoreleasepool {
        XCTAssertTrue(delegates.count == 1, @"Delegates should contain the new object");
        hello = nil;
    }
    
    XCTAssertTrue(delegates.count == 1, @"Delegates should still contain the object");
    [delegates foreach:^(id object, BOOL *stop) {
        XCTAssertTrue(object == nil, @"The delegate should be nil");
    }];
    
    NSString *hej = @"Hej verden";
    [delegates addDelegate:hej];
    XCTAssertTrue(delegates.count == 1, @"The old object should be gone and the new one should exist");
    [delegates foreach:^(id object, BOOL *stop) {
        XCTAssertTrue(object == hej, @"The delegate should be nil");
    }];
}

- (void)testAddDelegate_cannot_add_same_object_twice
{
    LEMultiDelegate *delegates = [LEMultiDelegate new];

    NSObject *hello = [[NSObject alloc] init];
    [delegates addDelegate:hello];
    [delegates addDelegate:hello];
    XCTAssertEqual(delegates.count, 1);
}


@end
