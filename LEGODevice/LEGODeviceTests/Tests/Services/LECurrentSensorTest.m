//
// Created by Søren Toft Odgaard on 15/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEIOStub.h"
#import "LECurrentSensor.h"
#import "LEService+Project.h"
#import "LEInputFormat.h"
#import "LEConnectInfo+Project.h"

@interface LECurrentSensorTest : LETestCase <LECurrentSensorDelegate> 
@end

@implementation LECurrentSensorTest {

    LECurrentSensor *_sensor;
    CGFloat _notifiedValue;
}

- (void)setUp
{
    [super setUp];

    LEIOStub *ioStub = [LEIOStub new];
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:LEIOTypeTiltSensor];
    _sensor = [[LECurrentSensor alloc] initWithConnectInfo:connectInfo io:ioStub];
    [_sensor addDelegate:self];
}

- (void)testHandleUpdatedValue_SI
{
    //Setup test
    [self updateSensorUnit:LEInputFormatUnitSI];
    Float32 value = 0.10;

    //Execute method under test
    [self updateValueWithData:[NSData dataWithBytes:&value length:sizeof(value)]];

    //Verify
    XCTAssertEqual(value, _sensor.milliAmp);
    XCTAssertEqual(_notifiedValue, _sensor.milliAmp);
}

- (void)testHandleUpdatedValue_Raw
{
    //Setup test
    [self updateSensorUnit:LEInputFormatUnitRaw];
    Float32 value = 3000.10;

    //Execute method under test
    [self updateValueWithData:[NSData dataWithBytes:&value length:sizeof(value)]];

    //Verify
    XCTAssertEqual(0.0, _sensor.milliAmp);
    XCTAssertEqual(_notifiedValue, 0.0);
    XCTAssertEqual(value, _sensor.valueAsFloat); //It should be possible to get the raw value from the 'generic'  method
}

- (void)testHandleUpdatedValue_Pct
{
    [self updateSensorUnit:LEInputFormatUnitPercentage];
    int32_t value = 99;

    //Execute method under test
    [self updateValueWithData:[NSData dataWithBytes:&value length:sizeof(value)]];

    //Verify
    XCTAssertEqual(0.0, _sensor.milliAmp);
    XCTAssertEqual(_notifiedValue, 0.0);
    XCTAssertEqual(value, _sensor.valueAsInteger); //It should be possible to get the raw value from the 'generic'  method
}

- (void)updateValueWithData:(NSData *)data {
    NSError *error;
    [_sensor handleUpdatedValueData:data error:&error];
    XCTAssertNil(error, @"Did not expect error from handleUpdatedValueData: %@", error.localizedDescription);
}



- (void)updateSensorUnit:(LEInputFormatUnit)unit
{
    LEInputFormat *inputFormat = [_sensor.defaultInputFormat inputFormatBySettingMode:_sensor.defaultInputFormat.mode unit:unit];
    [_sensor handleUpdatedInputFormat:inputFormat];
}


- (void)currentSensor:(LECurrentSensor *)sensor didUpdateMilliAmp:(CGFloat)milliAmp
{
    _notifiedValue = milliAmp;
}


@end