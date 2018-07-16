//
// Created by Søren Toft Odgaard on 08/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEIOStub.h"
#import "LEService+Project.h"
#import "LEMotionSensor.h"
#import "LETestStubFactory.h"
#import "LEInputFormat+Project.h"
#import "LEConnectInfo+Project.h"

@interface LEMotionSensorTest : LETestCase <LEMotionSensorDelegate>
@end

@implementation LEMotionSensorTest {

    LEMotionSensor *_motionSensor;
    CGFloat _notifiedDistance;
    NSUInteger _notifiedCount;
}

- (void)setUp
{
    [super setUp];

    LEIOStub *ioStub = [LEIOStub new];
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:LEIOTypeMotionSensor];
    _motionSensor = [LEMotionSensor serviceWithConnectInfo:connectInfo io:ioStub];
    [_motionSensor addDelegate:self];

}


- (void)testHandleUpdatedValue_detect_mode_Raw
{
    //Setup test
    [self updateInputFormatMode:LEMotionSensorModeDetect unit:LEInputFormatUnitRaw numberOfBytes:1];

    [self updateValueWithData:[NSData dataFromHexString:@"01"]];
    XCTAssertEqual(1.0, _motionSensor.distance);
    XCTAssertEqual(1.0, _notifiedDistance);

    [self updateValueWithData:[NSData dataFromHexString:@"64"]];
    XCTAssertEqual((CGFloat) 0x64, _motionSensor.distance);
    XCTAssertEqual((CGFloat) 0x64, _notifiedDistance);

    XCTAssertEqual(0U, _notifiedCount);
}

- (void)testHandleUpdatedValue_detect_mode_percentage
{
    //Setup test
    [self updateInputFormatMode:LEMotionSensorModeDetect unit:LEInputFormatUnitPercentage numberOfBytes:1];

    [self updateValueWithData:[NSData dataFromHexString:@"01"]];
    XCTAssertEqual(1.0, _motionSensor.distance);
    XCTAssertEqual(1.0, _notifiedDistance);

    [self updateValueWithData:[NSData dataFromHexString:@"64"]];
    XCTAssertEqual((CGFloat) 0x64, _motionSensor.distance);
    XCTAssertEqual((CGFloat) 0x64, _notifiedDistance);
}


- (void)testHandleUpdatedValue_detect_mode_SI
{
    //Setup test
    [self updateInputFormatMode:LEMotionSensorModeDetect unit:LEInputFormatUnitSI numberOfBytes:4];

    Float32 value = 123.45;
    [self updateValueWithData:[NSData dataWithBytes:&value length:sizeof(value)]];
    XCTAssertEqual(value, _motionSensor.distance);
    XCTAssertEqual(value, _notifiedDistance);

    value = (Float32) -123.45;
    [self updateValueWithData:[NSData dataWithBytes:&value length:sizeof(value)]];
    XCTAssertEqual(value, _motionSensor.distance);
    XCTAssertEqual(value, _notifiedDistance);
}


- (void)testHandleUpdatedValue_count_mode_raw
{
    //Setup test
    [self updateInputFormatMode:LEMotionSensorModeCount unit:LEInputFormatUnitRaw numberOfBytes:4];

    uint32_t count = 12345;
    NSData *countData = [NSData dataWithBytes:&count length:sizeof(count)];
    [self updateValueWithData:countData];
    XCTAssertEqual(count, _notifiedCount);
    XCTAssertEqual(count, _motionSensor.count);

    XCTAssertEqual(0U, _notifiedDistance);
}

- (void)testHandleUpdatedValue_count_mode_percentage
{
    //Setup test
    [self updateInputFormatMode:LEMotionSensorModeCount unit:LEInputFormatUnitPercentage numberOfBytes:1];

    uint8_t count = 99;
    NSData *countData = [NSData dataWithBytes:&count length:sizeof(count)];
    [self updateValueWithData:countData];
    XCTAssertEqual((NSUInteger) count, _notifiedCount);
    XCTAssertEqual((NSUInteger) count, _motionSensor.count);

    XCTAssertEqual(0U, _notifiedDistance);
}


- (void)testHandleUpdatedValue_count_mode_SI
{
    //Setup test
    [self updateInputFormatMode:LEMotionSensorModeCount unit:LEInputFormatUnitSI numberOfBytes:4];

    Float32 count = 12345.12;
    NSData *countData = [NSData dataWithBytes:&count length:sizeof(count)];
    [self updateValueWithData:countData];
    XCTAssertEqual((NSUInteger) count, _notifiedCount);
    XCTAssertEqual((NSUInteger) count, _motionSensor.count);

    XCTAssertEqual(0U, _notifiedDistance);
}

- (void)testSetMotionSensorMode
{
    id ioMock = [OCMockObject niceMockForClass:[LEIO class]];
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:LEIOTypeMotionSensor];
    _motionSensor = [LEMotionSensor serviceWithConnectInfo:connectInfo io:ioMock];

    //Setup expected moc invocations
    LEInputFormat *format = [_motionSensor.defaultInputFormat inputFormatBySettingMode:LEMotionSensorModeCount];
    [[ioMock expect] writeInputFormat:format forConnectID:connectInfo.connectID];

    //Run MUC
    _motionSensor.motionSensorMode = LEMotionSensorModeCount;

    //verify mock
    [ioMock verify];
}

- (void)updateValueWithData:(NSData *)data
{
    NSError *error = nil;
    [_motionSensor handleUpdatedValueData:data error:&error];
    XCTAssertNil(error, @"Did not expect error from hadleUpdatedValudeData: %@", error.localizedDescription);
}


#pragma mark - LEMotionSensorDelegate
- (void)service:(LEService *)service didUpdateValueDataFrom:(NSData *)oldValue to:(NSData *)newValue
{
    //It is easy to 'fix' the code to make this test fail when trying to 'cache' values in the TiltSensor
    //You should make sure that at the time this delegate is invoked, the value of the "direction"
    //will also return the updated value
    if (_motionSensor.motionSensorMode == LEMotionSensorModeDetect && _motionSensor.inputFormat.unit == LEInputFormatUnitRaw) {
        int8_t value;
        [newValue getBytes:&value length:1];
        XCTAssertEqual(_motionSensor.distance, value);
    }
}


- (void)motionSensor:(LEMotionSensor *)sensor didUpdateCountTo:(NSUInteger)count
{
    _notifiedCount = count;
}


- (void)motionSensor:(LEMotionSensor *)sensor didUpdateDistanceFrom:(CGFloat)oldDistance to:(CGFloat)newDistance
{
    _notifiedDistance = newDistance;
}


- (void)updateInputFormatMode:(LEMotionSensorMode)mode unit:(LEInputFormatUnit)unit numberOfBytes:(uint8_t)numberOfBytes
{
    NSData *data = [LETestStubFactory inputFormatWriteDataWithRevision:1 connectID:_motionSensor.connectInfo.connectID
            typeID:_motionSensor.connectInfo.type mode:mode deltaInterval:1 unit:unit notificationsEnabled:YES numberOfBytes:numberOfBytes];
    LEInputFormat *format = [LEInputFormat inputFormatWithData:data];
    [_motionSensor handleUpdatedInputFormat:format];
}


@end