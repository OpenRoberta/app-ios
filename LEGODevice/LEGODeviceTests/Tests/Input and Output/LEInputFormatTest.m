//
//  LEInputFormatTest.m
//  LEGODevice
//
//  Created by Søren Toft Odgaard on 22/04/14.
//  Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSData+Hex.h"
#import "LEInputFormat.h"
#import "LEConnectInfo.h"
#import "LEInputFormat+Project.h"
#import "LETestCase.h"
#import "LETestStubFactory.h"


@interface LEInputFormatTest : LETestCase

@end

@implementation LEInputFormatTest

- (void)testCreateInputFormatFromData
{

    UInt8 formatVersion = 2;

    NSData *formatWriteData = [LETestStubFactory
            inputFormatWriteDataWithRevision:formatVersion
            connectID:1
            typeID:LEIOTypeMotionSensor
            mode:0
            deltaInterval:12345
            unit:1
            notificationsEnabled:1
            numberOfBytes:2];

    LEInputFormat *format1 = [LEInputFormat inputFormatWithData:formatWriteData];
    XCTAssertNotNil(format1);
    XCTAssertEqual(format1.revision, (uint8_t) 2);
    XCTAssertEqual(format1.connectID, (uint8_t) 1);
    XCTAssertEqual(format1.typeID, (uint8_t) LEIOTypeMotionSensor);
    XCTAssertEqual(format1.mode, (uint8_t) 0);
    XCTAssertEqual(format1.deltaInterval, (uint32_t) 12345);
    XCTAssertEqual(format1.unit, 1);
    XCTAssertTrue(format1.notificationsEnabled);
    XCTAssertEqual(format1.numberOfBytes, (uint8_t) 2);

}


- (void)testCreateInputFormatWriteData
{
    //Setup expected result
    NSMutableString *expectedResultHex = [NSMutableString string];
    [expectedResultHex appendString:@"28"]; //Type 40 in hex
    [expectedResultHex appendString:@"00"]; //Mode
    [expectedResultHex appendString:@"01 00 00 00"]; //Delta interval (four bytes)
    [expectedResultHex appendString:@"01"]; //Unit Percentage
    [expectedResultHex appendString:@"01"]; //Notifications enabled
    NSData *expectedResult = [NSData dataFromHexString:expectedResultHex];

    //Run method under test
    LEInputFormat *format = [LEInputFormat
            inputFormatWithConnectID:2
            typeID:40
            mode:0
            deltaInterval:1
            unit:LEInputFormatUnitPercentage
            notificationsEnabled:YES];
    NSMutableData *actualResult = format.writeFormatData;

    //Verify Results
    XCTAssertEqualObjects(actualResult, expectedResult);
}

@end
