//
//  LEDeviceInfoTest.m
//  LEGODeviceDemo
//
//  Created by Søren Toft Odgaard on 28/05/14.
//  Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LETestCase.h"
#import "LEDeviceInfo+Project.h"

@interface LEDeviceInfoTest : LETestCase

@end

@implementation LEDeviceInfoTest

- (void)testEquals
{
    LEDeviceInfo *deviceInfoA = [LEDeviceInfo deviceInfo];
    LEDeviceInfo *deviceInfoB = [LEDeviceInfo deviceInfo];

    XCTAssertEqualObjects(deviceInfoA, deviceInfoB);
    XCTAssertEqualObjects(deviceInfoB, deviceInfoA);

    deviceInfoA = [deviceInfoA deviceInfoBySettingHardwareRevisionString:@"0.0.1"];
    XCTAssertNotEqualObjects(deviceInfoA, deviceInfoB);
    XCTAssertNotEqualObjects(deviceInfoB, deviceInfoA);

    deviceInfoB = [deviceInfoB deviceInfoBySettingHardwareRevisionString:@"0.0.1"];
    XCTAssertEqualObjects(deviceInfoA, deviceInfoB);
    XCTAssertEqualObjects(deviceInfoB, deviceInfoA);

    deviceInfoA = [deviceInfoA deviceInfoBySettingFirmwareRevisionString:@"1"];
    deviceInfoA = [deviceInfoA deviceInfoBySettingFirmwareRevisionString:@"2"];
    deviceInfoA = [deviceInfoA deviceInfoBySettingManufactureName:@"LEGO Systems"];
    deviceInfoB = [deviceInfoB deviceInfoBySettingFirmwareRevisionString:@"1"];
    deviceInfoB = [deviceInfoB deviceInfoBySettingFirmwareRevisionString:@"2"];
    deviceInfoB = [deviceInfoB deviceInfoBySettingManufactureName:@"LEGO Systems"];
    XCTAssertEqualObjects(deviceInfoA, deviceInfoB);
    XCTAssertEqualObjects(deviceInfoB, deviceInfoA);
}

- (void)testIsComplete
{
    LEDeviceInfo *deviceInfo = [LEDeviceInfo deviceInfo];

    deviceInfo = [deviceInfo deviceInfoBySettingHardwareRevisionString:@"0.0.1"];
    XCTAssertFalse(deviceInfo.isComplete);

    deviceInfo = [deviceInfo deviceInfoBySettingFirmwareRevisionString:@"1"];
    deviceInfo = [deviceInfo deviceInfoBySettingSoftwareRevisionString:@"2"];
    deviceInfo = [deviceInfo deviceInfoBySettingManufactureName:@"LEGO Systems"];
    XCTAssertTrue(deviceInfo.isComplete);
}

- (void)testRevisionFromStringParsing {
    
    LEDeviceInfo *deviceInfo = [LEDeviceInfo deviceInfo];
    deviceInfo = [deviceInfo deviceInfoBySettingHardwareRevisionString:@"1.2.03.004"];
    
    XCTAssertEqual(deviceInfo.hardwareRevision.majorVersion, 1);
    XCTAssertEqual(deviceInfo.hardwareRevision.minorVersion, 2);
    XCTAssertEqual(deviceInfo.hardwareRevision.bugFixVersion, 3);
    XCTAssertEqual(deviceInfo.hardwareRevision.buildNumber, 4);
}

- (void)testRevisionComponents_success_scenario
{
    LEDeviceInfo *deviceInfo = [LEDeviceInfo deviceInfo];

    XCTAssertNil(deviceInfo.firmwareRevision);
    XCTAssertNil(deviceInfo.softwareRevision);
    XCTAssertNil(deviceInfo.hardwareRevision);

    deviceInfo = [deviceInfo deviceInfoBySettingFirmwareRevisionString:@"1"];
    XCTAssertEqual(deviceInfo.firmwareRevision.majorVersion, 1U);
    XCTAssertEqual(deviceInfo.firmwareRevision.minorVersion, 0U);
    XCTAssertEqual(deviceInfo.firmwareRevision.bugFixVersion, 0U);

    deviceInfo = [deviceInfo deviceInfoBySettingFirmwareRevisionString:@"0.2"];
    XCTAssertEqual(deviceInfo.firmwareRevision.majorVersion, 0U);
    XCTAssertEqual(deviceInfo.firmwareRevision.minorVersion, 2U);
    XCTAssertEqual(deviceInfo.firmwareRevision.bugFixVersion, 0U);

    deviceInfo = [deviceInfo deviceInfoBySettingFirmwareRevisionString:@"1.2.99.200"];
    XCTAssertEqual(deviceInfo.firmwareRevision.majorVersion, 1U);
    XCTAssertEqual(deviceInfo.firmwareRevision.minorVersion, 2U);
    XCTAssertEqual(deviceInfo.firmwareRevision.bugFixVersion, 99U);
    XCTAssertEqual(deviceInfo.firmwareRevision.buildNumber, 200U);
}


- (void)testRevisionComponents_not_number_gives_zero_version_numbers
{
    LEDeviceInfo *deviceInfo = [LEDeviceInfo deviceInfo];
    deviceInfo = [deviceInfo deviceInfoBySettingFirmwareRevisionString:@"A.B.C"];
    XCTAssertNotNil(deviceInfo.firmwareRevision);

    XCTAssertEqual(deviceInfo.firmwareRevision.majorVersion, 0U);
    XCTAssertEqual(deviceInfo.firmwareRevision.minorVersion, 0U);
    XCTAssertEqual(deviceInfo.firmwareRevision.bugFixVersion, 0U);
}



@end
