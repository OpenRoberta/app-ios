//
//  LEGODeviceWrapperTest.m
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 01/04/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEGODeviceUnityWrapper.h"
#import "LEGOWrapperSerialization.h"
#import "LEGOUnityInvoker.h"
#import "LEGODevice.h"
#import "LEDeviceInfo+Project.h"
#import "LEGODeviceSDK-Native.h"
#import "UnityCallbacks.h"


@interface LEGODeviceWrapperTest : LETestCase

@property (strong, nonatomic) LEGODeviceUnityWrapper * deviceWrapper;

@property (strong, nonatomic) id deviceManagerMock;

@property (strong, nonatomic) id deviceMock;
@property (strong, nonatomic) NSString * deviceID;

@property (strong, nonatomic) id serviceMock;

@property (strong, nonatomic) id serializationMock;
@property (strong, nonatomic) id unityInvokerMock;

@end


@implementation LEGODeviceWrapperTest

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    
    self.deviceWrapper = [LEGODeviceUnityWrapper sharedInstance];
    
    self.deviceManagerMock = [OCMockObject niceMockForClass:[LEDeviceManager class]];
    [[[self.deviceManagerMock stub] andReturn:self.deviceManagerMock] sharedDeviceManager];
    
    self.deviceID = @"TestDevice-123";
    self.deviceMock = [OCMockObject niceMockForClass:[LEDevice class]];
    [[[self.deviceMock stub] andReturn:self.deviceID] deviceId];
    
    self.serviceMock = [OCMockObject niceMockForClass:[LEService class]];
    
    self.serializationMock = [OCMockObject niceMockForClass:[LEGOWrapperSerialization class]];
    
    self.unityInvokerMock = [OCMockObject mockForClass:[LEGOUnityInvoker class]];
}

- (void)tearDown
{
    [self.deviceManagerMock stopMocking];
    [self.serializationMock stopMocking];
    
    [super tearDown];
}

#pragma mark - Tests

#pragma mark API Methods

- (void)testDeviceChangeName
{
    // Setup
    NSString *newName = @"FooBar-1";
    [[[self.deviceManagerMock expect] andReturn:@[self.deviceMock]] allDevices];
    [[self.deviceMock expect] setName:newName];
    
    // Test
    LEGODevice_updateDeviceName([self.deviceID UTF8String], [newName UTF8String]);
    
    // Verify
    [self.deviceManagerMock verify];
    [self.deviceMock verify];
}

#pragma mark Delegates/events

- (void)testDeviceDidAddService
{
    // Setup
    [[self.serializationMock expect] serializeService:self.serviceMock];
    [[self.unityInvokerMock expect] invokeMethod:LEDeviceDidAddService withData:OCMOCK_ANY];
    
    // Test
    [self.deviceWrapper device:self.deviceMock didAddService:self.serviceMock];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testDeviceDidRemoveService
{
    // Setup
    [[self.serializationMock expect] serializeService:self.serviceMock onlyBasicInfo:YES];
    [[self.unityInvokerMock expect] invokeMethod:LEDeviceDidRemoveService withData:OCMOCK_ANY];
    
    // Test
    [self.deviceWrapper device:self.deviceMock didRemoveService:self.serviceMock];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testDeviceDidChangeButtonState
{
    // Setup
    [[self.serializationMock expect] serializeDevice:self.deviceMock buttonStateChange:YES];
    [[self.unityInvokerMock expect] invokeMethod:LEDeviceDidChangeButtonState withData:OCMOCK_ANY];
    
    // Test
    [self.deviceWrapper device:self.deviceMock didChangeButtonState:YES];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testDeviceDidChangeName
{
    // Setup
    NSString *oldName = @"OldName";
    NSString *newName = @"NewName";
    [[self.serializationMock expect] serializeDevice:self.deviceMock nameChangeFrom:oldName to:newName];
    [[self.unityInvokerMock expect] invokeMethod:LEDeviceDidChangeName withData:OCMOCK_ANY];
    
    // Test
    [self.deviceWrapper device:self.deviceMock didChangeNameFrom:oldName to:newName];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testDeviceDidFailToAddServiceWithError
{
    // Setup
    NSError *error = [NSError errorWithDomain:@"com.lego.ble.test" code:1 userInfo:nil];
    [[self.serializationMock expect] serializeDevice:self.deviceMock error:error];
    [[self.unityInvokerMock expect] invokeMethod:LEDeviceDidFailToAddServiceWithError withData:OCMOCK_ANY];
    
    // Test
    [self.deviceWrapper device:self.deviceMock didFailToAddServiceWithError:error];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testDeviceDidUpdateBatteryLevel
{
    // Setup
    NSInteger batteryLevel = 72;
    [[self.serializationMock expect] serializeDevice:self.deviceMock batteryLevel:batteryLevel];
    [[self.unityInvokerMock expect] invokeMethod:LEDeviceDidUpdateBatteryLevel withData:OCMOCK_ANY];
    
    // Test
    [self.deviceWrapper device:self.deviceMock didUpdateBatteryLevel:@(batteryLevel)];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

- (void)testDeviceDidUpdateDeviceInfo
{
    // Setup
    LEDeviceInfo *deviceInfo = [LEDeviceInfo deviceInfo];
    [[self.serializationMock expect] serializeDevice:self.deviceMock];
    [[self.unityInvokerMock expect] invokeMethod:LEDeviceDidUpdateDeviceInfo withData:OCMOCK_ANY];
    
    // Test
    [self.deviceWrapper device:self.deviceMock didUpdateDeviceInfo:deviceInfo error:nil];
    
    // Verify
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

@end
