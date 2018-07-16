//
//  LEGOServiceWrapperTest.m
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 01/04/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEGODevice.h"
#import "LEGOServiceUnityWrapper.h"
#import "LEConnectInfo+Project.h"
#import "LEGOWrapperSerialization.h"
#import "LEGOUnityInvoker.h"
#import "LEInputFormat+Project.h"
#import "LEGODeviceSDK-Native.h"
#import "UnityCallbacks.h"


// Macros for converting from NSStrings and integer types to C strings
#define CStr(nsstring) [nsstring UTF8String]
#define IntCStr(integer) [[@(integer) stringValue] UTF8String]


@interface LEGOServiceWrapperTest : LETestCase

@property (strong, nonatomic) LEGOServiceUnityWrapper * serviceWrapper;

@property (strong, nonatomic) id deviceManagerMock;

@property (strong, nonatomic) id deviceMock;
@property (strong, nonatomic) NSString * deviceID;

@property (strong, nonatomic) id serviceMock;
@property (strong, nonatomic) NSString * serviceConnectID;

@property (strong, nonatomic) id serializationMock;
@property (strong, nonatomic) id unityInvokerMock;

@end

@implementation LEGOServiceWrapperTest

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    
    self.serviceWrapper = [LEGOServiceUnityWrapper sharedInstance];
    self.serializationMock = [OCMockObject niceMockForClass:[LEGOWrapperSerialization class]];
    self.unityInvokerMock = [OCMockObject mockForClass:[LEGOUnityInvoker class]];
    
    self.deviceID = @"TestDevice-123";
    self.serviceConnectID = @"1";
}

- (void)tearDown
{
    [self.deviceManagerMock stopMocking];
    [self.serializationMock stopMocking];
    
    [super tearDown];
}

- (void)prepareServiceMockOfClass:(Class)serviceClass
{
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:(uint8_t)[self.serviceConnectID integerValue] hubIndex:0 type:0];
    self.serviceMock = [OCMockObject niceMockForClass:serviceClass];
    [[[self.serviceMock stub] andReturn:connectInfo] connectInfo];
    
    self.deviceMock = [OCMockObject niceMockForClass:[LEDevice class]];
    [[[self.deviceMock stub] andReturn:self.deviceID] deviceId];
    [[[self.deviceMock stub] andReturn:@[self.serviceMock]] services];
    
    self.deviceManagerMock = [OCMockObject niceMockForClass:[LEDeviceManager class]];
    [[[self.deviceManagerMock stub] andReturn:self.deviceManagerMock] sharedDeviceManager];
    [[[self.deviceManagerMock stub] andReturn:@[self.deviceMock]] allDevices];
}

#pragma mark - Tests

#pragma mark API Methods

- (void)testUpdateServiceData
{
    // Setup
    [self prepareServiceMockOfClass:[LEService class]];
    [[self.serializationMock expect] serializeServiceWithData:self.serviceMock];
    [[self.unityInvokerMock expect] invokeMethod:LEServiceUpdateServiceData withData:OCMOCK_ANY];
    
    // Test
    LEGOService_updateServiceData([self.deviceID UTF8String], [self.serviceConnectID UTF8String]);
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testUpdateInputFormat
{
    // Setup
    uint8_t mode = 2;
    uint32_t deltaInterval = 15;
    LEInputFormatUnit unit = LEInputFormatUnitRaw;
    BOOL notificationsEnabled = YES;
    
    [self prepareServiceMockOfClass:[LEService class]];
    [[self.serviceMock expect] updateInputFormat:[OCMArg checkWithBlock:^BOOL(LEInputFormat *inputFormat) {
        return inputFormat.mode == mode &&
            inputFormat.deltaInterval == deltaInterval &&
            inputFormat.unit == unit &&
            inputFormat.notificationsEnabled == notificationsEnabled;
    }]];
    
    // Test
    LEGOService_updateInputFormat(CStr(self.deviceID), CStr(self.serviceConnectID), IntCStr(mode), IntCStr(unit), IntCStr(deltaInterval), notificationsEnabled);
    
    // Verify
    [self.serviceMock verify];
}

- (void)testMotorRun
{
    // Setup
    LEMotorDirection direction = LEMotorDirectionLeft;
    NSUInteger power = 77;

    [self prepareServiceMockOfClass:[LEMotor class]];
    [[self.serviceMock expect] runInDirection:direction power:power];
    
    // Test
    LEGOService_run(CStr(self.deviceID), CStr(self.serviceConnectID), IntCStr(direction), IntCStr(power));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testMotorBrake
{
    // Setup
    [self prepareServiceMockOfClass:[LEMotor class]];
    [[self.serviceMock expect] brake];
    
    // Test
    LEGOService_brake(CStr(self.deviceID), CStr(self.serviceConnectID));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testMotorDrift
{
    // Setup
    [self prepareServiceMockOfClass:[LEMotor class]];
    [[self.serviceMock expect] drift];
    
    // Test
    LEGOService_drift(CStr(self.deviceID), CStr(self.serviceConnectID));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testLightChangeMode
{
    // Setup
    [self prepareServiceMockOfClass:[LERGBLight class]];
    [[self.serviceMock expect] setRgbMode:1];
    
    // Test
    LEGOService_setRGBLightMode(CStr(self.deviceID), CStr(self.serviceConnectID), IntCStr(1));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testLightSwitchOff
{
    // Setup
    [self prepareServiceMockOfClass:[LERGBLight class]];
    [[self.serviceMock expect] switchOff];
    
    // Test
    LEGOService_switchOff(CStr(self.deviceID), CStr(self.serviceConnectID));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testLightChangeColorToDefault
{
    // Setup
    [self prepareServiceMockOfClass:[LERGBLight class]];;
    [(LERGBLight *)[self.serviceMock expect] switchToDefaultColor];
    
    // Test
    LEGOService_changeColorToDefault(CStr(self.deviceID), CStr(self.serviceConnectID));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testLightChangeColor
{
    // Setup
    NSString *colorJSONString = @"not a real color";
    CIColor *color = [CIColor colorWithRed:1 green:0.5 blue:0.25];
    
    [self prepareServiceMockOfClass:[LERGBLight class]];
    // since we're not testing color deserialization here let's stub it to return a valid color for invalid JSON string
    [[[self.serializationMock expect] andReturn:color] deserializeColor:OCMOCK_ANY];
    [(LERGBLight *)[self.serviceMock expect] setColor:color];
    
    // Test
    LEGOService_changeColor(CStr(self.deviceID), CStr(self.serviceConnectID), CStr(colorJSONString));
    
    // Verify
    [self.serviceMock verify];
    [self.serializationMock verify];
}

- (void)testLightChangeColorIndex
{
    // Setup
    int colorIndex = 2;
    [self prepareServiceMockOfClass:[LERGBLight class]];
    [(LERGBLight *)[self.serviceMock expect] setColorIndex:colorIndex];
    
    // Test
    LEGOService_changeColorIndex(CStr(self.deviceID), CStr(self.serviceConnectID), IntCStr(colorIndex));
    
    // Verify
    [self.serviceMock verify];    
}

- (void)testMotionSensorSetMode
{
    // Setup
    LEMotionSensorMode mode = LEMotionSensorModeCount;
    
    [self prepareServiceMockOfClass:[LEMotionSensor class]];
    [[self.serviceMock expect] setMotionSensorMode:mode];
    
    // Test
    LEGOService_setMotionSensorMode(CStr(self.deviceID), CStr(self.serviceConnectID), IntCStr(mode));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testTiltSensorSetMode
{
    // Setup
    LETiltSensorMode mode = LETiltSensorModeCrash;
    
    [self prepareServiceMockOfClass:[LETiltSensor class]];
    [[self.serviceMock expect] setTiltSensorMode:mode];
    
    // Test
    LEGOService_setTiltSensorMode(CStr(self.deviceID), CStr(self.serviceConnectID), IntCStr(mode));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testPiezoPlayerPlayFrequency
{
    // Setup
    NSUInteger frequency = 5000;
    NSUInteger milliseconds = 350;
    
    [self prepareServiceMockOfClass:[LEPiezoTonePlayer class]];
    [[self.serviceMock expect] playFrequency:frequency forMilliseconds:milliseconds];
    
    // Test
    LEGOService_playFrequency(CStr(self.deviceID), CStr(self.serviceConnectID), IntCStr(frequency), IntCStr(milliseconds));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testPiezoPlayerPlayNote
{
    // Setup
    LEPiezoTonePlayerNote note = LEPiezoTonePlayerNoteB;
    NSUInteger octave = 2;
    NSUInteger milliseconds = 350;
    
    [self prepareServiceMockOfClass:[LEPiezoTonePlayer class]];
    [[self.serviceMock expect] playNote:note octave:octave forMilliSeconds:milliseconds];
    
    // Test
    LEGOService_playNote(CStr(self.deviceID), CStr(self.serviceConnectID), IntCStr(note), IntCStr(octave), IntCStr(milliseconds));
    
    // Verify
    [self.serviceMock verify];
}

- (void)testPiezoPlayerStopPlaying
{
    // Setup
    [self prepareServiceMockOfClass:[LEPiezoTonePlayer class]];
    [[self.serviceMock expect] stopPlaying];
    
    // Test
    LEGOService_stopPlaying(CStr(self.deviceID), CStr(self.serviceConnectID));
    
    // Verify
    [self.serviceMock verify];
}

#pragma mark Delegates/events

- (void)testServiceDidUpdateInputFormat
{
    // Setup
    [self prepareServiceMockOfClass:[LEService class]];
    LEInputFormat *oldInputFormat = [LEInputFormat inputFormatWithConnectID:1 typeID:2 mode:3 deltaInterval:10 unit:LEInputFormatUnitSI notificationsEnabled:YES];
    LEInputFormat *newInputFormat = [LEInputFormat inputFormatWithConnectID:1 typeID:2 mode:4 deltaInterval:30 unit:LEInputFormatUnitRaw notificationsEnabled:NO];
    
    [[self.serializationMock expect] serializeService:self.serviceMock inputFormatChangeFrom:oldInputFormat to:newInputFormat];
    [[self.unityInvokerMock expect] invokeMethod:LEServiceDidUpdateInputFormat withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper service:self.serviceMock didUpdateInputFormatFrom:oldInputFormat to:newInputFormat];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testServiceDidUpdateValueData
{
    // Setup
    [self prepareServiceMockOfClass:[LEService class]];
    // the exact data doesn't really matter, we're only interested in different data pointers
    NSData *oldData = [NSData dataWithBytes:"a" length:1];
    NSData *newData = [NSData dataWithBytes:"b" length:1];
    
    [[self.serializationMock expect] serializeService:self.serviceMock valueDataChangeFrom:oldData to:newData];
    [[self.unityInvokerMock expect] invokeMethod:LEServiceDidUpdateValueData withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper service:self.serviceMock didUpdateValueDataFrom:oldData to:newData];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testCurrentSensorDidUpdateMilliAmps
{
    // Setup
    [self prepareServiceMockOfClass:[LECurrentSensor class]];
    CGFloat current = 3.14;
    
    [[self.serializationMock expect] serializeCurrentSensor:self.serviceMock currentChangeTo:current];
    [[self.unityInvokerMock expect] invokeMethod:LECurrentSensorDidUpdateMilliAmp withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper currentSensor:self.serviceMock didUpdateMilliAmp:current];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testVoltageSensorDidUpdateMilliVolts
{
    // Setup
    [self prepareServiceMockOfClass:[LEVoltageSensor class]];
    CGFloat voltage = 1234.0;
    
    [[self.serializationMock expect] serializeVoltageSensor:self.serviceMock voltageChangeTo:voltage];
    [[self.unityInvokerMock expect] invokeMethod:LEVoltageSensorDidUpdateMilliVolts withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper voltageSensor:self.serviceMock didUpdateMilliVolts:voltage];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testMotionSensorDidUpdateCount
{
    // Setup
    [self prepareServiceMockOfClass:[LEMotionSensor class]];
    NSUInteger count = 35;
    
    [[self.serializationMock expect] serializeMotionSensor:self.serviceMock countChangeTo:count];
    [[self.unityInvokerMock expect] invokeMethod:LEMotionSensorDidUpdateCount withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper motionSensor:self.serviceMock didUpdateCountTo:count];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testMotionSensorDidUpdateDistance
{
    // Setup
    [self prepareServiceMockOfClass:[LEMotionSensor class]];
    CGFloat oldDistance = 6;
    CGFloat newDistance = 8;
    
    [[self.serializationMock expect] serializeMotionSensor:self.serviceMock distanceChangeFrom:oldDistance to:newDistance];
    [[self.unityInvokerMock expect] invokeMethod:LEMotionSensorDidUpdateDistance withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper motionSensor:self.serviceMock didUpdateDistanceFrom:oldDistance to:newDistance];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testRGBLightDidUpdateColor
{
    // Setup
    [self prepareServiceMockOfClass:[LERGBLight class]];
    CIColor *oldColor = [CIColor colorWithRed:1 green:1 blue:1];
    CIColor *newColor = [CIColor colorWithRed:0.5 green:0.5 blue:0.5];
    
    [[self.serializationMock expect] serializeRGBLight:self.serviceMock colorChangeFrom:oldColor to:newColor];
    [[self.unityInvokerMock expect] invokeMethod:LERGBLightDidUpdateColor withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper rgbLight:self.serviceMock didUpdateColorFrom:oldColor to:newColor];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testRGBLightDidUpdateColorIndex
{
    // Setup
    [self prepareServiceMockOfClass:[LERGBLight class]];
    NSUInteger oldColorIndex = 1;
    NSUInteger newColorIndex = 2;
    
    [[self.serializationMock expect] serializeRGBLightIndex:self.serviceMock colorChangeFromIndex:oldColorIndex to:newColorIndex];
    [[self.unityInvokerMock expect] invokeMethod:LERGBLightDidUpdateColorIndex withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper rgbLight:self.serviceMock didUpdateColorIndexFrom:oldColorIndex to:newColorIndex];

    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testTiltSensorDidUpdateAngle
{
    // Setup
    [self prepareServiceMockOfClass:[LETiltSensor class]];
    LETiltSensorAngle oldAngle = LETiltSensorAngleMake(10, 10);
    LETiltSensorAngle newAngle = LETiltSensorAngleMake(20, 20);
    
    [[self.serializationMock expect] serializeTiltSensor:self.serviceMock angleChangeFrom:oldAngle to:newAngle];
    [[self.unityInvokerMock expect] invokeMethod:LETiltSensorDidUpdateAngle withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper tiltSensor:self.serviceMock didUpdateAngleFrom:oldAngle to:newAngle];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testTiltSensorDidUpdateCrash
{
    // Setup
    [self prepareServiceMockOfClass:[LETiltSensor class]];
    LETiltSensorCrash oldCrash = LETiltSensorCrashMake(1, 2, 3);
    LETiltSensorCrash newCrash = LETiltSensorCrashMake(7, 8, 9);
    
    [[self.serializationMock expect] serializeTiltSensor:self.serviceMock crashChangeFrom:oldCrash to:newCrash];
    [[self.unityInvokerMock expect] invokeMethod:LETiltSensorDidUpdateCrash withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper tiltSensor:self.serviceMock didUpdateCrashFrom:oldCrash to:newCrash];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testTiltSensorDidUpdateDirection
{
    // Setup
    [self prepareServiceMockOfClass:[LETiltSensor class]];
    LETiltSensorDirection oldDirection = LETiltSensorDirectionLeft;
    LETiltSensorDirection newDirection = LETiltSensorDirectionRight;
    
    [[self.serializationMock expect] serializeTiltSensor:self.serviceMock directionChangeFrom:oldDirection to:newDirection];
    [[self.unityInvokerMock expect] invokeMethod:LETiltSensorDidUpdateDirection withData:OCMOCK_ANY];
    
    // Test
    [self.serviceWrapper tiltSensor:self.serviceMock didUpdateDirectionFrom:oldDirection to:newDirection];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

@end
