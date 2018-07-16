//
//  LERGBLightTest.m
//  LEGODeviceDemo
//
//  Created by Søren Toft Odgaard on 21/05/14.
//  Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LETestCase.h"
#import "LEConnectInfo+Project.h"
#import "LERGBLight.h"
#import "LEDevice.h"
#import "LEDeviceInfo+Project.h"
#import "LEService+Project.h"
#import "CIColor+LEAdditional.h"
#import "LEInputFormat+Project.h"
#import "LETestStubFactory.h"

@interface LERGBLightTest : LETestCase <LERGBLightDelegate>

@end

@implementation LERGBLightTest {
    LEConnectInfo *_connectInfo;
    id _ioMock;
    id _deviceMock;
    LERGBLight *_rgbLight;
    NSData *_notifiedColorData;
    CIColor *_notifiedColor;
    NSUInteger _notifiedColorIndex;
}

- (void)setUp
{
    [super setUp];

    //Setup a device with fiwmare revision 1.0, as some services behave differently depending on firmware revision
    LEDeviceInfo *info = [LEDeviceInfo deviceInfo];
    info = [info deviceInfoBySettingFirmwareRevisionString:@"1.0.0.0"];
    _deviceMock = [OCMockObject niceMockForClass:[LEDevice class]];
    [[[_deviceMock stub] andReturn:info] deviceInfo];
    
    _connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:LEIOTypePiezoTone];

    _ioMock = [OCMockObject niceMockForClass:[LEIO class]];
    [[_ioMock expect] addDelegate:[OCMArg any]];
    
    _rgbLight = [[LERGBLight alloc] initWithConnectInfo:_connectInfo io:_ioMock];
    [_rgbLight setDevice:_deviceMock];

    [self updateInputFormatMode:_rgbLight.absoluteModeIndex unit:LEInputFormatUnitRaw numberOfBytes:3];
    
    [_rgbLight addDelegate:self];
}

- (void)updateInputFormatMode:(uint8_t)mode unit:(LEInputFormatUnit)unit numberOfBytes:(uint8_t)numberOfBytes
{
    NSData *data = [LETestStubFactory
                    inputFormatWriteDataWithRevision:1 connectID:_rgbLight.connectInfo.connectID typeID:_rgbLight.connectInfo.type
                    mode:mode deltaInterval:1 unit:unit notificationsEnabled:YES numberOfBytes:numberOfBytes];
    LEInputFormat *format = [LEInputFormat inputFormatWithData:data];
    [_rgbLight handleUpdatedInputFormat:format];
}


- (void)tearDown
{
    [super tearDown];
    [_rgbLight removeDelegate:self];
}


#pragma mark - LERGBModeAbsoloute (three values, one for red, blue and green itensity)

- (void)testSetAbsoluteColor_success
{
    uint8_t red = 0;
    uint8_t green = 100;
    uint8_t blue = 255;

    //Setup expected invocations of mock object
    [[_ioMock expect] writeColorRed:red green:green blue:blue connectID:_connectInfo.connectID];

    //Execute MUC
    _rgbLight.color = [CIColor colorWithIntRed:red green:green blue:blue];

    //Verify
    [_ioMock verify];


    XCTAssertEqualObjects(_rgbLight.color, [CIColor colorWithIntRed:red green:green blue:blue]);
}

- (void)testSetAbosoluteColor_ignored_when_in_discrete_mode
{
    [self updateInputFormatMode:_rgbLight.discreteModeIndex unit:LEInputFormatUnitRaw numberOfBytes:1];
    
    uint8_t red = 0;
    uint8_t green = 100;
    uint8_t blue = 255;
    
    //Execute MUC
    _rgbLight.color = [CIColor colorWithIntRed:red green:green blue:blue];
    
    //Verify
    XCTAssertNil(_rgbLight.color);
}


- (NSData *)dataWithRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue
{
    NSMutableData *data = [NSMutableData dataWithCapacity:3];
    [data appendBytes:&red length:sizeof(red)];
    [data appendBytes:&green length:sizeof(green)];
    [data appendBytes:&blue length:sizeof(blue)];
    return data;
}

- (void)testSwitchOff_absolute_mode
{
    //Setup expected invocations of mock object
    [[_ioMock expect] writeColorRed:0 green:0 blue:0 connectID:_connectInfo.connectID];

    //Execute MUT
    [_rgbLight switchOff];

    //Verify
    [_ioMock verify];

    XCTAssertEqualObjects(_rgbLight.color, [CIColor colorWithRed:0 green:0 blue:0]);
}

- (void)testSwithToDefaultColor_absolute_mode
{
    //Setup expected invocations of mock object
    [[_ioMock expect] writeColorRed:0 green:0 blue:0xFF connectID:_connectInfo.connectID];

    //Execute MUT
    [_rgbLight switchToDefaultColor];
    
    //Verify
    [_ioMock verify];
    
    XCTAssertEqualObjects(_rgbLight.color, [CIColor colorWithRed:0 green:0 blue:0xFF]);
}


- (void)testHandleUpdatedValue_abolute_raw
{
    uint8_t red = 0;
    uint8_t green = 100;
    uint8_t blue = 255;

    NSError *error;
    [_rgbLight handleUpdatedValueData:[self dataWithRed:red green:green blue:blue] error:&error];
    XCTAssertNil(error, @"Did not expect error from handleUpdatedValueData: %@", error.localizedDescription);

    CIColor *expectedColor = [CIColor colorWithIntRed:red green:green blue:blue];

    XCTAssertEqualObjects(_rgbLight.color, expectedColor);
    XCTAssertEqualObjects(_notifiedColor, expectedColor);
    XCTAssertEqualObjects(_notifiedColorData, [NSData dataFromHexString:@"0064FF"]);
}

#pragma mark - LERGBModeDiscrete (an index of a color)

- (void)testSetDiscreteColor_success
{
    [self updateInputFormatMode:_rgbLight.discreteModeIndex unit:LEInputFormatUnitRaw numberOfBytes:1];
    
    uint8_t colorIndex = 1;
    
    //Setup expected invocations of mock object
    [[_ioMock expect] writeColorIndex:colorIndex connectID:_connectInfo.connectID];
    
    //Execute MUC
    _rgbLight.colorIndex = 1;
    
    //Verify
    [_ioMock verify];
    
    XCTAssertEqual(_rgbLight.colorIndex, 1);
}


- (void)testSwitchOff_discrete_mode
{
    [self updateInputFormatMode:_rgbLight.discreteModeIndex unit:LEInputFormatUnitRaw numberOfBytes:1];
    
    //Setup expected invocations of mock object
    [[_ioMock expect] writeColorIndex:0 connectID:_connectInfo.connectID];
    
    //Execute MUT
    [_rgbLight switchOff];
    
    //Verify
    [_ioMock verify];
    
    XCTAssertEqual(_rgbLight.colorIndex, 0);
}

- (void)testSwithToDefaultColor_discrete_mode
{
    [self updateInputFormatMode:_rgbLight.discreteModeIndex unit:LEInputFormatUnitRaw numberOfBytes:1];
    
    //Setup expected invocations of mock object
    [[_ioMock expect] writeColorIndex:3 connectID:_connectInfo.connectID]; //Color index 3 happens to be the default color :-)
    
    //Execute MUT
    [_rgbLight switchToDefaultColor];
    
    //Verify
    [_ioMock verify];
    
    XCTAssertEqual(_rgbLight.colorIndex, (NSUInteger) 3);
}



#pragma mark - LERGBLightDelegate
- (void)service:(LEService *)service didUpdateValueDataFrom:(NSData *)oldValue to:(NSData *)newValue
{
    _notifiedColorData = newValue;
}

- (void)rgbLight:(LERGBLight *)rgbLight didUpdateColorIndexFrom:(NSUInteger)oldColorIndex to:(NSUInteger)newColorIndex
{
    _notifiedColorIndex = newColorIndex;
}

- (void)rgbLight:(LERGBLight *)rgbLight didUpdateColorFrom:(CIColor *)oldColor to:(CIColor *)newValue
{
    _notifiedColor = newValue;
}

@end
