//
//  LEBloutoothHelperTests.m
//  LEGODevice
//
//  Created by Jon Nørrelykke on 13/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LEBluetoothHelper.h"
#import "LETestCase.h"

@interface LEBluetoothHelperTest : LETestCase

@end

@implementation LEBluetoothHelperTest

- (void)testUUIDBuilding
{
    XCTAssertEqualObjects([LEBluetoothHelper UUIDWithPrefix:@"00001560"],   @"00001560-1212-EFDE-1523-785FEABCD123");
    XCTAssertEqualObjects([LEBluetoothHelper UUIDWithPrefix:@"001560"],     @"00001560-1212-EFDE-1523-785FEABCD123");
    XCTAssertEqualObjects([LEBluetoothHelper UUIDWithPrefix:@"1560"],       @"00001560-1212-EFDE-1523-785FEABCD123");
}

- (void)testCharacteristicPropertiesToStrings {

    CBCharacteristicProperties props = (CBCharacteristicPropertyNotify | CBCharacteristicWriteWithoutResponse | CBCharacteristicPropertyRead);

    NSArray *propString = [LEBluetoothHelper arrayOfStringsFromCharacteristicProperties:props];

    NSLog(@"Strings: %@", propString);



}



@end
