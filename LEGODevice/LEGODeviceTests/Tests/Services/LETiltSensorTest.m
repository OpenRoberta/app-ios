//  LETiltSensorTest.m
//  LEGODevice
//
//  Created by Jon Nørrelykke on 20/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LETestCase.h"
#import "LEBluetoothIO.h"
#import "LEService+Project.h"
#import "LEIOStub.h"
#import "LEInputFormat.h"
#import "LETestStubFactory.h"
#import "LEInputFormat+Project.h"
#import "LEConnectInfo+Project.h"
#import "NSData+Test.h"

@interface LETiltSensorTest : LETestCase <LETiltSensorDelegate>

@end

@implementation LETiltSensorTest {

    LETiltSensorAngle _notifiedAngle;
    NSUInteger _notifiedDirection;
    LETiltSensorCrash _notifiedCrash;

    LETiltSensor *_tiltSensor;
}

- (void)setUp
{
    [super setUp];

    LEIOStub *ioStub = [LEIOStub new];
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:LEIOTypeTiltSensor];
    _tiltSensor = [LETiltSensor serviceWithConnectInfo:connectInfo io:ioStub];
    [_tiltSensor addDelegate:self];
}

- (void)tearDown
{
    [super tearDown];
    [_tiltSensor removeDelegate:self];
}


#pragma mark - Test Angle Mode

- (void)testHandleUpdatedValue_angle_mode_raw_success_scenario
{
    //Setup test
    [self updateInputFormatMode:LETiltSensorModeAngle unit:LEInputFormatUnitRaw numberOfBytes:2];

    //Execute method under test
    [self updateValueWithData:[NSData dataFromHexString:@"01 02"]];

    //Verify result
    LETiltSensorAngle expectedResult = LETiltSensorAngleMake(1, 2);
    XCTAssertTrue(LETiltSensorAngleEqualToAngle(expectedResult, _tiltSensor.angle));
    XCTAssertTrue(LETiltSensorAngleEqualToAngle(expectedResult, _notifiedAngle));
}

- (void)testHandleUpdatedValue_angle_mode_SI_success_scenario
{
    //Setup test
    [self updateInputFormatMode:LETiltSensorModeAngle unit:LEInputFormatUnitSI numberOfBytes:2*4];

    //Execute method under test
    NSData *data = [self dataWithX:10.10 y:20.20];
    [self updateValueWithData:data];

    //Verify result
    LETiltSensorAngle expectedResult = LETiltSensorAngleMake(10.10, 20.20);
    XCTAssertTrue(LETiltSensorAngleEqualToAngle(expectedResult, _tiltSensor.angle), @"Acutal result x: %f, y: %f", _tiltSensor.angle.x, _tiltSensor.angle.y);
    XCTAssertTrue(LETiltSensorAngleEqualToAngle(expectedResult, _notifiedAngle));
}

- (void)testHandleUpdatedValue_angle_mode_pct_success_scenario
{
    //Setup test
    [self updateInputFormatMode:LETiltSensorModeAngle unit:LEInputFormatUnitPercentage numberOfBytes:2];

    //Execute method under test
    [self updateValueWithData:[NSData dataFromHexString:@"32 64"]];

    //Verify result
    LETiltSensorAngle expectedResult = LETiltSensorAngleMake(0x32, 0x64);
    XCTAssertTrue(LETiltSensorAngleEqualToAngle(expectedResult, _tiltSensor.angle));
    XCTAssertTrue(LETiltSensorAngleEqualToAngle(expectedResult, _notifiedAngle));
}


#pragma mark - Test Tilt Mode

- (void)testHandleUpdatedValue_tilt_mode_raw_success_scenario
{
    //Setup test
    [self updateInputFormatMode:LETiltSensorModeTilt unit:LEInputFormatUnitRaw numberOfBytes:1];

    //Execute method under test
    [self updateValueWithData:[NSData dataFromHexString:@"09"]]; //09 = Forward

    //Verify result
    XCTAssertEqual(LETiltSensorDirectionForward, _tiltSensor.direction);
    XCTAssertEqual(LETiltSensorDirectionForward, _notifiedDirection);
}

- (void)testHandleUpdatedValue_all_tilt_mode_raw_values
{
    [self updateInputFormatMode:LETiltSensorModeTilt unit:LEInputFormatUnitRaw numberOfBytes:1];

    [self testHandleUpdatedValueHexStr:@"00" mapsToDirection:LETiltSensorDirectionNeutral];
    [self testHandleUpdatedValueHexStr:@"03" mapsToDirection:LETiltSensorDirectionBackward];
    [self testHandleUpdatedValueHexStr:@"05" mapsToDirection:LETiltSensorDirectionRight];
    [self testHandleUpdatedValueHexStr:@"07" mapsToDirection:LETiltSensorDirectionLeft];
    [self testHandleUpdatedValueHexStr:@"09" mapsToDirection:LETiltSensorDirectionForward];
}

//Si mode should just return the same values as in raw
- (void)testHandleUpdatedValue_tilt_mode_SI_success_scenario
{
    //Setup test
    [self updateInputFormatMode:LETiltSensorModeTilt unit:LEInputFormatUnitSI numberOfBytes:4];

    //Execute method under test
    [self updateValueWithData:[NSData dataWithFloat1:7]]; //07 = Left

    //Verify result
    XCTAssertEqual(LETiltSensorDirectionLeft, _tiltSensor.direction);
}


- (void)testHandleUpdatedValueHexStr:(NSString *)valueHex mapsToDirection:(LETiltSensorDirection)direction
{
    [self updateValueWithData:[NSData dataFromHexString:valueHex]];
    XCTAssertEqual(direction, _tiltSensor.direction);
}

- (void)testHandleUpdatedValue_tilt_mode_crash_raw
{
    //Setup test
    [self updateInputFormatMode:LETiltSensorModeCrash unit:LEInputFormatUnitRaw numberOfBytes:3];

    //Execute method under test (did crash)
    [self updateValueWithData:[NSData dataFromHexString:@"010203"]];

    //Verify result
    LETiltSensorCrash expectedResult = LETiltSensorCrashMake(1, 2, 3);
    XCTAssertTrue(LETiltSensorCrashEqualToCrash(expectedResult, _tiltSensor.crash));
    XCTAssertTrue(LETiltSensorCrashEqualToCrash(expectedResult, _notifiedCrash));
}

- (void)testHandleUpdatedValue_tilt_mode_crash_percentage
{
    //Setup test
    [self updateInputFormatMode:LETiltSensorModeCrash unit:LEInputFormatUnitPercentage numberOfBytes:3];

    //Execute method under test (did crash)
    [self updateValueWithData:[NSData dataFromHexString:@"010203"]];

    //Verify result
    LETiltSensorCrash expectedResult = LETiltSensorCrashMake(1, 2, 3);
    XCTAssertTrue(LETiltSensorCrashEqualToCrash(expectedResult, _tiltSensor.crash));
    XCTAssertTrue(LETiltSensorCrashEqualToCrash(expectedResult, _notifiedCrash));
}

- (void)testHandleUpdatedValue_tilt_mode_crash_SI
{
    //Setup test
    [self updateInputFormatMode:LETiltSensorModeCrash unit:LEInputFormatUnitSI numberOfBytes:3*4];

    //Execute method under test (did crash)
    [self updateValueWithData:[self dataWithX:10.10 y:0.0 z:100.0]];

    //Verify result (we discard all decimals, as logically the crash value is a bump 'count' and thus an int should work fine)
    LETiltSensorCrash expectedResult = LETiltSensorCrashMake(10, 0, 100);
    XCTAssertTrue(LETiltSensorCrashEqualToCrash(expectedResult, _tiltSensor.crash));
    XCTAssertTrue(LETiltSensorCrashEqualToCrash(expectedResult, _notifiedCrash));
}


- (void)updateValueWithData:(NSData *)data
{
    NSError *error;
    [_tiltSensor handleUpdatedValueData:data error:&error];
    XCTAssertNil(error, @"Did not expect error from hadleUpdatedValudeData: %@", error.localizedDescription);
}


- (NSData *)dataWithX:(Float32)x y:(Float32)y
{
    NSMutableData *updateData = [NSMutableData dataWithCapacity:8];
    [updateData appendBytes:&x length:sizeof(x)];
    [updateData appendBytes:&y length:sizeof(y)];
    return updateData;
}

- (NSData *)dataWithX:(Float32)x y:(Float32)y z:(Float32)z
{
    NSMutableData *updateData = [NSMutableData dataWithCapacity:12];
    [updateData appendBytes:&x length:sizeof(x)];
    [updateData appendBytes:&y length:sizeof(y)];
    [updateData appendBytes:&z length:sizeof(z)];
    return updateData;
}

- (void)updateInputFormatMode:(LETiltSensorMode)mode unit:(LEInputFormatUnit)unit numberOfBytes:(uint8_t)numberOfBytes
{
    NSData *data = [LETestStubFactory inputFormatWriteDataWithRevision:1 connectID:_tiltSensor.connectInfo.connectID
            typeID:_tiltSensor.connectInfo.type mode:mode deltaInterval:1 unit:unit notificationsEnabled:YES numberOfBytes:numberOfBytes];
    LEInputFormat *format = [LEInputFormat inputFormatWithData:data];
    [_tiltSensor handleUpdatedInputFormat:format];
}



#pragma mark - LETiltSensorDelegate

- (void)service:(LEService *)service didUpdateValueDataFrom:(NSData *)oldValue to:(NSData *)newValue
{
    //It is easy to 'fix' the code to make this test fail when trying to 'cache' values in the TiltSensor
    //You should make sure that at the time this delegate is invoked, the value of the "direction"
    //will also return the updated value
    if (_tiltSensor.tiltSensorMode == LETiltSensorModeTilt && _tiltSensor.inputFormat.unit == LEInputFormatUnitRaw) {
        uint8_t value;
        [newValue getBytes:&value length:1];
        XCTAssertEqual(_tiltSensor.direction, value);
    }
}

- (void)tiltSensor:(LETiltSensor *)sensor didUpdateAngleFrom:(LETiltSensorAngle)oldAngle to:(LETiltSensorAngle)newAngle
{
    _notifiedAngle = newAngle;
}

- (void)tiltSensor:(LETiltSensor *)sensor didUpdateDirectionFrom:(LETiltSensorDirection)oldDirection to:(LETiltSensorDirection)newDirection
{
    _notifiedDirection = newDirection;
}

- (void)tiltSensor:(LETiltSensor *)sensor didUpdateCrashFrom:(LETiltSensorCrash)oldCrashValue to:(LETiltSensorCrash)newCrashValue
{
    _notifiedCrash = newCrashValue;
}




@end
