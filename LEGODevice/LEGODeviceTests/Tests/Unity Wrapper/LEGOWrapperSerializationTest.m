//
//  WrapperSerializationTest.m
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 27/03/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEGOWrapperSerialization.h"
#import "LEDevice.h"
#import "LEDeviceInfo+Project.h"
#import "LEInputFormat.h"
#import "LEConnectInfo+Project.h"
#import "LERevision+Project.h"
#import "LEService+Project.h"
#import "LEMotor.h"
#import "LERGBLight.h"
#import "LEMotionSensor.h"
#import "LETiltSensor.h"
#import "LEVoltageSensor.h"
#import "LECurrentSensor.h"
#import "LEPiezoTonePlayer.h"
#import "LEInputFormat+Project.h"

@interface FooBarService : LEService
@end

@implementation FooBarService
@end


@interface LEGOWrapperSerializationTest : LETestCase

@property (strong, nonatomic) NSString * deviceID;
@property (strong, nonatomic) id deviceMock;

// Second mocked device used only by the multiple device serialization test
@property (strong, nonatomic) NSString * deviceID2;
@property (strong, nonatomic) id deviceMock2;

@property (strong, nonatomic) NSNumber * serviceConnectID;
@property (strong, nonatomic) id serviceMock;

@end


@implementation LEGOWrapperSerializationTest

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    
    self.deviceID = @"DeviceID";
    self.deviceMock = [self prepareDeviceMockWithID:self.deviceID];
    
    self.deviceID2 = @"AnotherDevice-123";
    self.deviceMock2 = [self prepareDeviceMockWithID:self.deviceID2];
    
    self.serviceConnectID = @2;
    self.serviceMock = [self prepareServiceMockOfClass:[LEService class]];
}

- (void)tearDown
{
    [super tearDown];
}

- (id)prepareDeviceMockWithID:(NSString *)deviceID
{
    LEDeviceInfo *deviceInfo = [LEDeviceInfo deviceInfo];
    deviceInfo = [deviceInfo deviceInfoBySettingFirmwareRevisionString:@"1.1.1.1"];
    deviceInfo = [deviceInfo deviceInfoBySettingSoftwareRevisionString:@"2.2.2.2"];
    deviceInfo = [deviceInfo deviceInfoBySettingHardwareRevisionString:@"3.3.3.3"];
    deviceInfo = [deviceInfo deviceInfoBySettingManufactureName:@"LEGO"];
    
    id deviceMock = [OCMockObject niceMockForClass:[LEDevice class]];
    [[[deviceMock stub] andReturn:deviceInfo] deviceInfo];
    [[[deviceMock stub] andReturn:@"DeviceName"] name];
    [[[deviceMock stub] andReturn:deviceID] deviceId];
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(YES)] isButtonPressed];
    [[[deviceMock stub] andReturn:@90.0] batteryLevel];
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(LEDeviceStateInterrogating)] connectState];
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(LEDeviceCategoryDuplo)] category];
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE(LEDeviceFunctionActsAsRemoteController)] supportedFunctions];
    [[[deviceMock stub] andReturnValue:OCMOCK_VALUE((NSUInteger)4)] lastConnectedNetworkId];

    return deviceMock;
}

- (id)prepareServiceMockOfClass:(Class)serviceClass
{
    LEInputFormat *inputFormat = [LEInputFormat inputFormatWithConnectID:1 typeID:2 mode:3 deltaInterval:10 unit:LEInputFormatUnitSI notificationsEnabled:YES];
    LEInputFormat *defaultInputFormat = [LEInputFormat inputFormatWithConnectID:5 typeID:7 mode:8 deltaInterval:30 unit:LEInputFormatUnitRaw notificationsEnabled:NO];
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:(uint8_t)[self.serviceConnectID intValue] hubIndex:1 type:(uint8_t)LEIOTypeGeneric hardwareVersion:[LERevision revisionWithString:@"1.1.1.1"] firmwareVersion:[LERevision revisionWithString:@"2.2.2.2"]];
    
    id serviceMock = [OCMockObject niceMockForClass:serviceClass];
    [[[serviceMock stub] andReturn:@"Test service"] serviceName];
    [[[serviceMock stub] andReturn:inputFormat] inputFormat];
    [[[serviceMock stub] andReturn:defaultInputFormat] defaultInputFormat];
    [[[serviceMock stub] andReturnValue:OCMOCK_VALUE(YES)] isInternalService];
    [[[serviceMock stub] andReturn:connectInfo] connectInfo];
    [[[serviceMock stub] andReturn:self.deviceMock] device];
    
    return serviceMock;
}

#pragma mark - Tests -

#pragma mark Device

- (void)verifySerializedDevice:(NSDictionary *)serializedDevice withMock:(id)mock onlyBasic:(BOOL)onlyBasic
{
    NSParameterAssert(mock == self.deviceMock || mock == self.deviceMock2);
    
    XCTAssertEqualObjects(serializedDevice[@"DeviceID"], mock == self.deviceMock ? self.deviceID : self.deviceID2, @"DeviceID not matching");
    if (onlyBasic == YES) {
        return;
    }
    
    XCTAssertEqualObjects(serializedDevice[@"DeviceName"], @"DeviceName", @"Device name not matching");
    XCTAssertEqualObjects(serializedDevice[@"ButtonPressed"], @YES, @"Button pressed state not matching");
    XCTAssertEqualObjects(serializedDevice[@"BatteryLevel"], @90, @"Battery level not matching");
    XCTAssertEqualObjects(serializedDevice[@"ConnectedState"], @3, @"Connection state not matching");
    XCTAssertEqualObjects(serializedDevice[@"Category"], @1, @"Device category not matching");
    XCTAssertEqualObjects(serializedDevice[@"SupportedFunctions"], @3, @"Supported functions not matching");
    XCTAssertEqualObjects(serializedDevice[@"LastConnectedNetworkId"], @4, @"Last connected network ID not matching");

    NSDictionary *serializedDeviceInfo = (NSDictionary *)serializedDevice[@"DeviceInfo"];
    XCTAssertEqualObjects(serializedDeviceInfo[@"FirmwareRevision"], @"1.1.1.1", @"Firmware revision not matching");
    XCTAssertEqualObjects(serializedDeviceInfo[@"SoftwareRevision"], @"2.2.2.2", @"Software revision not matching");
    XCTAssertEqualObjects(serializedDeviceInfo[@"HardwareRevision"], @"3.3.3.3", @"Hardware revision not matching");
    XCTAssertEqualObjects(serializedDeviceInfo[@"ManufacturerName"], @"LEGO", @"Manufacturer name not matching");
}

- (void)testDevice
{
    // Setup
    id deviceMock = self.deviceMock;
    
    // Test
    NSDictionary *serializedDevice = [LEGOWrapperSerialization serializeDevice:deviceMock];
    
    // Verify
    [self verifySerializedDevice:serializedDevice withMock:deviceMock onlyBasic:NO];
}

- (void)testDevices
{
    // Setup
    NSArray *deviceMocks = @[self.deviceMock, self.deviceMock2];
    
    // Test
    NSArray *serializedDevices = [LEGOWrapperSerialization serializeDevices:deviceMocks];
    
    // Verify
    XCTAssertEqual(serializedDevices.count, 2, @"Expected two serialized devices");
    [self verifySerializedDevice:serializedDevices[0] withMock:deviceMocks[0] onlyBasic:NO];
    [self verifySerializedDevice:serializedDevices[1] withMock:deviceMocks[1] onlyBasic:NO];
}

#pragma mark Device events

- (void)testDeviceNameChange
{
    // Setup
    id deviceMock = self.deviceMock;
    NSString *deviceOldName = @"OldName";
    NSString *deviceNewName = @"NewName";
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeDevice:deviceMock nameChangeFrom:deviceOldName to:deviceNewName];
    
    // Verify
    [self verifySerializedDevice:serialized withMock:deviceMock onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"OldDeviceName"], deviceOldName);
    XCTAssertEqualObjects(serialized[@"DeviceName"], deviceNewName);
}

- (void)testDeviceButtonStateChange
{
    // Setup
    id deviceMock = self.deviceMock;
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeDevice:deviceMock buttonStateChange:YES];
    
    // Verify
    [self verifySerializedDevice:serialized withMock:deviceMock onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"ButtonState"], @YES);
}

- (void)testDeviceBatteryLevel
{
    // Setup
    id deviceMock = self.deviceMock;
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeDevice:deviceMock batteryLevel:42];
    
    // Verify
    [self verifySerializedDevice:serialized withMock:deviceMock onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"BatteryLevel"], @42);
}

- (void)testDeviceError
{
    // Setup
    id deviceMock = self.deviceMock;
    NSString *errorDescription = @"some error";
    NSError *error = [NSError errorWithDomain:@"com.lego.ble.test" code:1 userInfo:@{NSLocalizedDescriptionKey: errorDescription}];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeDevice:deviceMock error:error];
    
    // Verify
    [self verifySerializedDevice:serialized withMock:deviceMock onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"Error"], errorDescription);
}

#pragma mark Input format

- (void)testInputFormat
{
    // Setup
    LEInputFormat *inputFormat = [LEInputFormat inputFormatWithConnectID:1
                                                                  typeID:2
                                                                    mode:3
                                                           deltaInterval:10
                                                                    unit:LEInputFormatUnitSI
                                                    notificationsEnabled:YES];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeInputFormat:inputFormat];
    
    // Verify
    XCTAssertEqualObjects(serialized[@"Revision"], @(0));
    XCTAssertEqualObjects(serialized[@"ConnectID"], @(1));
    XCTAssertEqualObjects(serialized[@"TypeID"], @(2));
    XCTAssertEqualObjects(serialized[@"Mode"], @(3));
    XCTAssertEqualObjects(serialized[@"DeltaInterval"], @(10));
    XCTAssertEqualObjects(serialized[@"Unit"], @((uint8_t)LEInputFormatUnitSI));
    XCTAssertEqualObjects(serialized[@"NotificationsEnabled"], @YES);
}

#pragma mark Service

- (void)verifySerializedService:(NSDictionary *)serializedService onlyBasic:(BOOL)onlyBasic
{
    if (onlyBasic == YES) {
        XCTAssertEqualObjects(serializedService[@"DeviceID"], self.deviceID);
        XCTAssertEqualObjects(serializedService[@"ConnectID"], self.serviceConnectID);
        return;
    }
    
    XCTAssertEqualObjects(serializedService[@"ServiceName"], @"Test service");
    XCTAssertEqualObjects(serializedService[@"IsInternalService"], @YES);
    XCTAssertEqualObjects(serializedService[@"DeviceID"], self.deviceID);
    
    XCTAssertEqualObjects(serializedService[@"ConnectInfo"][@"ConnectID"], self.serviceConnectID);
    XCTAssertEqualObjects(serializedService[@"ConnectInfo"][@"HubIndex"], @1);
    XCTAssertEqualObjects(serializedService[@"ConnectInfo"][@"HardwareRevision"], @"1.1.1.1");
    XCTAssertEqualObjects(serializedService[@"ConnectInfo"][@"SoftwareRevision"], @"2.2.2.2");
    XCTAssertEqualObjects(serializedService[@"ConnectInfo"][@"Type"], @(LEIOTypeGeneric));
    
    XCTAssertEqualObjects(serializedService[@"InputFormat"][@"Revision"], @0);
    XCTAssertEqualObjects(serializedService[@"InputFormat"][@"ConnectID"], @1);
    XCTAssertEqualObjects(serializedService[@"InputFormat"][@"TypeID"], @2);
    XCTAssertEqualObjects(serializedService[@"InputFormat"][@"Mode"], @3);
    XCTAssertEqualObjects(serializedService[@"InputFormat"][@"DeltaInterval"], @10);
    XCTAssertEqualObjects(serializedService[@"InputFormat"][@"Unit"], @(LEInputFormatUnitSI));
    XCTAssertEqualObjects(serializedService[@"InputFormat"][@"NotificationsEnabled"], @YES);
    
    XCTAssertEqualObjects(serializedService[@"DefaultInputFormat"][@"Revision"], @0);
    XCTAssertEqualObjects(serializedService[@"DefaultInputFormat"][@"ConnectID"], @5);
    XCTAssertEqualObjects(serializedService[@"DefaultInputFormat"][@"TypeID"], @7);
    XCTAssertEqualObjects(serializedService[@"DefaultInputFormat"][@"Mode"], @8);
    XCTAssertEqualObjects(serializedService[@"DefaultInputFormat"][@"DeltaInterval"], @30);
    XCTAssertEqualObjects(serializedService[@"DefaultInputFormat"][@"Unit"], @(LEInputFormatUnitRaw));
    XCTAssertEqualObjects(serializedService[@"DefaultInputFormat"][@"NotificationsEnabled"], @NO);
}

- (void)testServiceFull
{
    // Setup
    id serviceMock = self.serviceMock;

    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeService:serviceMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
}

- (void)testServiceBasic
{
    // Setup
    id serviceMock = self.serviceMock;
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeService:serviceMock onlyBasicInfo:YES];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
}

- (void)testMotorServiceData
{
    // Setup
    id motorMock = [self prepareServiceMockOfClass:[LEMotor class]];
    [[[motorMock stub] andReturnValue:OCMOCK_VALUE((NSUInteger)24)] power];
    [(LEMotor *)[[motorMock stub] andReturnValue:OCMOCK_VALUE(LEMotorDirectionLeft)] direction];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeServiceWithData:motorMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
    NSDictionary *serviceData = serialized[@"ServiceData"];
    XCTAssertEqualObjects(serviceData[@"Power"], @24);
    XCTAssertEqualObjects(serviceData[@"MotorDirection"], @1);
}

- (void)testRGBLightServiceData
{
    // Setup
    id lightMock = [self prepareServiceMockOfClass:[LERGBLight class]];
    [[[lightMock stub] andReturnValue:OCMOCK_VALUE((uint8_t)1)] rgbMode];
    [[[lightMock stub] andReturn:[CIColor colorWithRed:1.0 green:0.5 blue:0.25 alpha:0.8]] color];
    [[[lightMock stub] andReturn:[CIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]] defaultColor];
    [[[lightMock stub] andReturnValue:OCMOCK_VALUE((NSUInteger)13)] colorIndex];
    [[[lightMock stub] andReturnValue:OCMOCK_VALUE((NSUInteger)7)] defaultColorIndex];

    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeServiceWithData:lightMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
    NSDictionary *serviceData = serialized[@"ServiceData"];
    XCTAssertEqualObjects(serviceData[@"RGBLightMode"], @1);
    XCTAssertEqualObjects(serviceData[@"Color"][@"R"], @((CGFloat)1.0));
    XCTAssertEqualObjects(serviceData[@"Color"][@"G"], @((CGFloat)0.5));
    XCTAssertEqualObjects(serviceData[@"Color"][@"B"], @((CGFloat)0.25));
    XCTAssertEqualObjects(serviceData[@"Color"][@"A"], @((CGFloat)0.8));
    XCTAssertEqualObjects(serviceData[@"DefaultColor"][@"R"],@((CGFloat) 0.7));
    XCTAssertEqualObjects(serviceData[@"DefaultColor"][@"G"], @((CGFloat)0.7));
    XCTAssertEqualObjects(serviceData[@"DefaultColor"][@"B"], @((CGFloat)0.7));
    XCTAssertEqualObjects(serviceData[@"DefaultColor"][@"A"], @((CGFloat)1.0));
    XCTAssertEqualObjects(serviceData[@"ColorIndex"], @13);
    XCTAssertEqualObjects(serviceData[@"DefaultColorIndex"], @7);
}

- (void)testMotionSensorServiceData
{
    // Setup
    id motionSensorMock = [self prepareServiceMockOfClass:[LEMotionSensor class]];
    [[[motionSensorMock stub] andReturnValue:OCMOCK_VALUE((NSUInteger)2)] count];
    [[[motionSensorMock stub] andReturnValue:OCMOCK_VALUE((CGFloat)3.14)] distance];
    [[[motionSensorMock stub] andReturnValue:OCMOCK_VALUE(LEMotionSensorModeDetect)] motionSensorMode];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeServiceWithData:motionSensorMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
    NSDictionary *serviceData = serialized[@"ServiceData"];
    XCTAssertEqualObjects(serviceData[@"Count"], @2);
    XCTAssertEqualObjects(serviceData[@"Distance"], @((CGFloat)3.14));
    XCTAssertEqualObjects(serviceData[@"MotionSensorMode"], @(LEMotionSensorModeDetect));
}

- (void)testTiltSensorServiceData
{
    // Setup
    LETiltSensorCrash crash = { 1, 2, 3 };
    LETiltSensorAngle angle = { 20.0f, 30.0f };
    
    id tiltSensorMock = [self prepareServiceMockOfClass:[LETiltSensor class]];
    [(LETiltSensor *)[[tiltSensorMock stub] andReturnValue:OCMOCK_VALUE(LETiltSensorDirectionRight)] direction];
    [[[tiltSensorMock stub] andReturnValue:OCMOCK_VALUE(LETiltSensorModeCrash)] tiltSensorMode];
    [[[tiltSensorMock stub] andReturnValue:OCMOCK_VALUE(crash)] crash];
    [[[tiltSensorMock stub] andReturnValue:OCMOCK_VALUE(angle)] angle];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeServiceWithData:tiltSensorMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
    NSDictionary *serviceData = serialized[@"ServiceData"];
    XCTAssertEqualObjects(serviceData[@"TiltSensorDirection"], @(LETiltSensorDirectionRight));
    XCTAssertEqualObjects(serviceData[@"TiltSensorMode"], @(LETiltSensorModeCrash));
    XCTAssertEqualObjects(serviceData[@"Crash"][@"X"], @1);
    XCTAssertEqualObjects(serviceData[@"Crash"][@"Y"], @2);
    XCTAssertEqualObjects(serviceData[@"Crash"][@"Z"], @3);
    XCTAssertEqualObjects(serviceData[@"Angle"][@"X"], @20);
    XCTAssertEqualObjects(serviceData[@"Angle"][@"Y"], @30);
}

- (void)testVoltageSensorServiceData
{
    // Setup
    id voltageSensorMock = [self prepareServiceMockOfClass:[LEVoltageSensor class]];
    [[[voltageSensorMock stub] andReturnValue:OCMOCK_VALUE((CGFloat)1234.25)] milliVolts];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeServiceWithData:voltageSensorMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
    NSDictionary *serviceData = serialized[@"ServiceData"];
    XCTAssertEqualObjects(serviceData[@"MilliVolts"], @1234.25);
}

- (void)testCurrentSensorServiceData
{
    // Setup
    id currentSensorMock = [self prepareServiceMockOfClass:[LECurrentSensor class]];
    [[[currentSensorMock stub] andReturnValue:OCMOCK_VALUE((CGFloat)1234.25)] milliAmp];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeServiceWithData:currentSensorMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
    NSDictionary *serviceData = serialized[@"ServiceData"];
    XCTAssertEqualObjects(serviceData[@"MilliAmp"], @1234.25);
}

- (void)testPiezoTonePlayerServiceData
{
    // Setup
    id piezoPlayerMock = [self prepareServiceMockOfClass:[LEPiezoTonePlayer class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeServiceWithData:piezoPlayerMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
    XCTAssertNil(serialized[@"ServiceData"], @"No service data should be generated for piezo tone player"); // at least for now
}

- (void)testUnknownServiceData
{
    // Setup
    id unknownServiceMock = [self prepareServiceMockOfClass:[FooBarService class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeServiceWithData:unknownServiceMock];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:NO];
    XCTAssertNil(serialized[@"ServiceData"], @"No service data should be generated for unknown services");
}

#pragma mark Service events

- (void)testServiceValueDataDidChange
{
    // Setup
    // the exact data doesn't really matter, we're only interested in different data pointers
    NSData *oldData = [NSData dataWithBytes:"a" length:1];
    NSData *newData = [NSData dataWithBytes:"b" length:1];
    id serviceMock = self.serviceMock;

    [[[serviceMock stub] andReturnValue:OCMOCK_VALUE(1.f)] floatFromData:oldData];
    [[[serviceMock stub] andReturnValue:OCMOCK_VALUE(2.f)] floatFromData:newData];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeService:serviceMock valueDataChangeFrom:oldData to:newData];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"OldValue"], @(1));
    XCTAssertEqualObjects(serialized[@"NewValue"], @(2));
}

- (void)testServiceInputFormatDidChange
{
    // Setup
    id serviceMock = self.serviceMock;
    LEInputFormat *oldInputFormat = [LEInputFormat inputFormatWithConnectID:1 typeID:2 mode:3 deltaInterval:10 unit:LEInputFormatUnitSI notificationsEnabled:YES];
    LEInputFormat *newInputFormat = [LEInputFormat inputFormatWithConnectID:1 typeID:2 mode:4 deltaInterval:30 unit:LEInputFormatUnitRaw notificationsEnabled:NO];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeService:serviceMock inputFormatChangeFrom:oldInputFormat to:newInputFormat];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    
    XCTAssertEqualObjects(serialized[@"OldInputFormat"][@"Revision"], @0);
    XCTAssertEqualObjects(serialized[@"OldInputFormat"][@"ConnectID"], @1);
    XCTAssertEqualObjects(serialized[@"OldInputFormat"][@"TypeID"], @2);
    XCTAssertEqualObjects(serialized[@"OldInputFormat"][@"Mode"], @3);
    XCTAssertEqualObjects(serialized[@"OldInputFormat"][@"DeltaInterval"], @10);
    XCTAssertEqualObjects(serialized[@"OldInputFormat"][@"Unit"], @(LEInputFormatUnitSI));
    XCTAssertEqualObjects(serialized[@"OldInputFormat"][@"NotificationsEnabled"], @YES);
    
    XCTAssertEqualObjects(serialized[@"NewInputFormat"][@"Revision"], @0);
    XCTAssertEqualObjects(serialized[@"NewInputFormat"][@"ConnectID"], @1);
    XCTAssertEqualObjects(serialized[@"NewInputFormat"][@"TypeID"], @2);
    XCTAssertEqualObjects(serialized[@"NewInputFormat"][@"Mode"], @4);
    XCTAssertEqualObjects(serialized[@"NewInputFormat"][@"DeltaInterval"], @30);
    XCTAssertEqualObjects(serialized[@"NewInputFormat"][@"Unit"], @(LEInputFormatUnitRaw));
    XCTAssertEqualObjects(serialized[@"NewInputFormat"][@"NotificationsEnabled"], @NO);
}

- (void)testMotionSensorDistanceDidChange
{
    // Setup
    id motionSensorMock = [self prepareServiceMockOfClass:[LEMotionSensor class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeMotionSensor:motionSensorMock distanceChangeFrom:42.0 to:3.14];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"OldDistance"], @((CGFloat)42.0));
    XCTAssertEqualObjects(serialized[@"NewDistance"], @((CGFloat)3.14));
}

- (void)testMotionSensorCountDidChange
{
    // Setup
    id motionSensorMock = [self prepareServiceMockOfClass:[LEMotionSensor class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeMotionSensor:motionSensorMock countChangeTo:4];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"Count"], @4);
}

- (void)testRGBLightColorDidChange
{
    // Setup
    id lightMock = [self prepareServiceMockOfClass:[LERGBLight class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeRGBLight:lightMock
                                                       colorChangeFrom:[CIColor colorWithRed:1 green:1 blue:1 alpha:1]
                                                                    to:[CIColor colorWithRed:1 green:0 blue:0 alpha:1]];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    
    XCTAssertEqualObjects(serialized[@"OldColor"][@"R"], @1);
    XCTAssertEqualObjects(serialized[@"OldColor"][@"G"], @1);
    XCTAssertEqualObjects(serialized[@"OldColor"][@"B"], @1);
    XCTAssertEqualObjects(serialized[@"OldColor"][@"A"], @1);
    
    XCTAssertEqualObjects(serialized[@"NewColor"][@"R"], @1);
    XCTAssertEqualObjects(serialized[@"NewColor"][@"G"], @0);
    XCTAssertEqualObjects(serialized[@"NewColor"][@"B"], @0);
    XCTAssertEqualObjects(serialized[@"NewColor"][@"A"], @1);
}

- (void)testTiltSensorDirectionDidChange
{
    // Setup
    id tiltSensorMock = [self prepareServiceMockOfClass:[LETiltSensor class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeTiltSensor:tiltSensorMock
                                                     directionChangeFrom:LETiltSensorDirectionLeft
                                                                      to:LETiltSensorDirectionForward];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"OldDirection"], @(LETiltSensorDirectionLeft));
    XCTAssertEqualObjects(serialized[@"NewDirection"], @(LETiltSensorDirectionForward));
}

- (void)testTiltSensorAngleDidChange
{
    // Setup
    id tiltSensorMock = [self prepareServiceMockOfClass:[LETiltSensor class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeTiltSensor:tiltSensorMock
                                                         angleChangeFrom:LETiltSensorAngleMake(10, 20)
                                                                      to:LETiltSensorAngleMake(15, 15)];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"OldAngle"][@"X"], @10);
    XCTAssertEqualObjects(serialized[@"OldAngle"][@"Y"], @20);
    XCTAssertEqualObjects(serialized[@"NewAngle"][@"X"], @15);
    XCTAssertEqualObjects(serialized[@"NewAngle"][@"Y"], @15);
}

- (void)testTiltSensorCrashDidChange
{
    // Setup
    id tiltSensorMock = [self prepareServiceMockOfClass:[LETiltSensor class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeTiltSensor:tiltSensorMock
                                                         crashChangeFrom:LETiltSensorCrashMake(1, 2, 3)
                                                                      to:LETiltSensorCrashMake(3, 5, 7)];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    
    XCTAssertEqualObjects(serialized[@"OldCrash"][@"X"], @1);
    XCTAssertEqualObjects(serialized[@"OldCrash"][@"Y"], @2);
    XCTAssertEqualObjects(serialized[@"OldCrash"][@"Z"], @3);
    
    XCTAssertEqualObjects(serialized[@"NewCrash"][@"X"], @3);
    XCTAssertEqualObjects(serialized[@"NewCrash"][@"Y"], @5);
    XCTAssertEqualObjects(serialized[@"NewCrash"][@"Z"], @7);
}

- (void)testVoltageSensorValueDidChange
{
    // Setup
    id voltageSensorMock = [self prepareServiceMockOfClass:[LEVoltageSensor class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeVoltageSensor:voltageSensorMock voltageChangeTo:2015.25];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"MilliVolts"], @2015.25);
}

- (void)testCurrentSensorValueDidChange
{
    // Setup
    id currentSensorMock = [self prepareServiceMockOfClass:[LECurrentSensor class]];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeCurrentSensor:currentSensorMock currentChangeTo:314.50];
    
    // Verify
    [self verifySerializedService:serialized onlyBasic:YES];
    XCTAssertEqualObjects(serialized[@"MilliAmp"], @314.5);
}

#pragma mark Helpers

- (void)testSerializeColor
{
    // Setup
    CIColor *color = [CIColor colorWithRed:0.25 green:0.5 blue:0.75 alpha:1.0];
    
    // Test
    NSDictionary *serialized = [LEGOWrapperSerialization serializeColor:color];
    
    // Verify
    XCTAssertEqualObjects(serialized[@"R"], @0.25);
    XCTAssertEqualObjects(serialized[@"G"], @0.5);
    XCTAssertEqualObjects(serialized[@"B"], @0.75);
    XCTAssertEqualObjects(serialized[@"A"], @1.0);
}

- (void)testDeserializeColor
{
    // Setup
    NSDictionary *color = @{ @"R": @0.25, @"G": @0.5, @"B": @0.75, @"A": @1.0 };
    
    // Test
    CIColor *deserialized = [LEGOWrapperSerialization deserializeColor:color];
    
    // Verify
    XCTAssertEqual(deserialized.red, 0.25);
    XCTAssertEqual(deserialized.green, 0.5);
    XCTAssertEqual(deserialized.blue, 0.75);
    XCTAssertEqual(deserialized.alpha, 1.0);
}

@end
