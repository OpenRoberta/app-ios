//
// Created by Søren Toft Odgaard on 15/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEVoltageSensor.h"
#import "LEInputFormat.h"
#import "LEService+Project.h"
#import "LEConnectInfo+Project.h"
#import "LEIOStub.h"

@interface LEVoltageSensorTest : LETestCase <LEVoltageSensorDelegate>
@end


@implementation LEVoltageSensorTest {
    LEVoltageSensor *_sensor;
    CGFloat _notifiedValue;
}

- (void)setUp
{
    [super setUp];

    LEIOStub *ioStub = [LEIOStub new];
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:LEIOTypeVoltage];
    _sensor = [[LEVoltageSensor alloc] initWithConnectInfo:connectInfo io:ioStub];
    [_sensor addDelegate:self];
}

- (void)tearDown
{
    [super tearDown];
    [_sensor removeDelegate:self];
}


- (void)testHandleUpdatedValue_default_mode_SI
{
    //Setup test
    [self updateSensorUnit:LEInputFormatUnitSI];
    Float32 value = 3000.10;

    //Execute method under test
    [self updateValueWithData:[NSData dataWithBytes:&value length:sizeof(value)]];

    //Verify
    XCTAssertEqual(value, _sensor.milliVolts);
    XCTAssertEqual(_notifiedValue, _sensor.milliVolts);
}



- (void)testHandleUpdatedValue_default_mode_raw
{
    //Setup test
    [self updateSensorUnit:LEInputFormatUnitRaw];
    Float32 value = 3000.10;

    //Execute method under test
    [self updateValueWithData:[NSData dataWithBytes:&value length:sizeof(value)]];

    //Verify
    XCTAssertEqual(0.0, _sensor.milliVolts);
    XCTAssertEqual(_notifiedValue, 0.0);
    XCTAssertEqual(value, _sensor.valueAsFloat); //It should be possible to get the raw value from the 'generic'  method
}

- (void)testHandleUpdatedValue_default_mode_percentage
{
    [self updateSensorUnit:LEInputFormatUnitPercentage];
    int32_t value = 99;

    //Execute method under test
    [self updateValueWithData:[NSData dataWithBytes:&value length:sizeof(value)]];

    //Verify
    XCTAssertEqual(0.0, _sensor.milliVolts);
    XCTAssertEqual(_notifiedValue, 0.0);
    XCTAssertEqual(value, _sensor.valueAsInteger); //It should be possible to get the raw value from the 'generic'  method
}

- (void)updateValueWithData:(NSData *)data {
    NSError *error;
    [_sensor handleUpdatedValueData:data error:&error];
    XCTAssertNil(error, @"Did not exepcgted error from hadleUpdatedValueData: %@", error.localizedDescription);
}


- (void)updateSensorUnit:(LEInputFormatUnit)unit
{
    LEInputFormat *inputFormat = [_sensor.defaultInputFormat inputFormatBySettingMode:_sensor.defaultInputFormat.mode unit:unit];
    [_sensor handleUpdatedInputFormat:inputFormat];
}


- (void)voltageSensor:(LEVoltageSensor *)sensor didUpdateMilliVolts:(CGFloat)milliVolts
{
    _notifiedValue = milliVolts;
}


@end