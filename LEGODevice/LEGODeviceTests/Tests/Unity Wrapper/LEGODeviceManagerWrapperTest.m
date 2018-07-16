//
//  LEGODeviceManagerWrapperTest.m
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 31/03/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEGODeviceManagerUnityWrapper.h"
#import "LEDeviceManager.h"
#import "LEGOWrapperSerialization.h"
#import "LEGOUnityInvoker.h"
#import "LEGODevice.h"
#import "LEGODeviceSDK-Native.h"


@interface LEGODeviceManagerWrapperTest : LETestCase

@property (strong, nonatomic) LEGODeviceManagerUnityWrapper * deviceManagerWrapper;

@property (strong, nonatomic) id deviceManagerMock;

@property (strong, nonatomic) id deviceMock;
@property (strong, nonatomic) NSString * deviceID;

@property (strong, nonatomic) id deviceMock2;

@property (strong, nonatomic) id serializationMock;

@property (strong, nonatomic) id unityInvokerMock;

@end


@implementation LEGODeviceManagerWrapperTest

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    
    self.deviceManagerWrapper = [LEGODeviceManagerUnityWrapper sharedInstance];
    
    self.deviceManagerMock = [OCMockObject niceMockForClass:[LEDeviceManager class]];
    [[[self.deviceManagerMock stub] andReturn:self.deviceManagerMock] sharedDeviceManager];
    
    self.deviceID = @"TestDevice-123";
    self.deviceMock = [OCMockObject niceMockForClass:[LEDevice class]];
    [[[self.deviceMock stub] andReturn:self.deviceID] deviceId];
    
    self.deviceMock2 = [OCMockObject mockForClass:[LEDevice class]];
    [[[self.deviceMock2 stub] andReturn:@"AnotherDevice-123456789"] deviceId];
    
    self.serializationMock = [OCMockObject niceMockForClass:[LEGOWrapperSerialization class]];
    
    self.unityInvokerMock = [OCMockObject mockForClass:[LEGOUnityInvoker class]];
}

- (void)tearDown
{
    [self.deviceManagerMock stopMocking];
    [self.serializationMock stopMocking];
    
    [super tearDown];
}

- (void)setupForDelegateCall:(NSString *)delegateName
{
    [[self.serializationMock expect] serializeDevice:self.deviceMock];
    [[self.unityInvokerMock expect] invokeMethod:delegateName withData:OCMOCK_ANY];
}

- (void)verifyDelegateCall
{
    [self.serializationMock verify];
    [self.unityInvokerMock verify];
}

#pragma mark - Tests

#pragma mark API Methods

- (void)testStartScanning
{
    // Setup
    [[self.deviceManagerMock expect] scan];
    
    // Test
    LEGODeviceManager_scan();
    
    // Verify
    [self.deviceManagerMock verify];
}

- (void)testStopScanning
{
    // Setup
    [[self.deviceManagerMock expect] stopScanning];
    
    // Test
    LEGODeviceManager_stopScanning();
    
    // Verify
    [self.deviceManagerMock verify];
}

- (void)testConnectToDevice
{
    // Setup
    [[[self.deviceManagerMock expect] andReturn:@[self.deviceMock]] allDevices];
    [[self.deviceManagerMock expect] connectToDevice:self.deviceMock];
    
    // Test
    LEGODeviceManager_connectToDevice([self.deviceID UTF8String]);
    
    // Verify
    [self.deviceManagerMock verify];
}

- (void)testDisconnectDevice
{
    // Setup
    [[[self.deviceManagerMock expect] andReturn:@[self.deviceMock]] allDevices];
    [[self.deviceManagerMock expect] cancelDeviceConnection:self.deviceMock];
    
    // Test
    LEGODeviceManager_disconnectDevice([self.deviceID UTF8String]);
    
    // Verify
    [self.deviceManagerMock verify];
}

- (void)testAllDevices
{
    // Setup
    [[[self.deviceManagerMock expect] andReturn:@[self.deviceMock, self.deviceMock2]] allDevices];

    // we need to return some data when serializing devices since WrapperSerialization expects that internally
    [[[self.serializationMock expect] andReturn:@{}] serializeDevice:self.deviceMock];
    [[[self.serializationMock expect] andReturn:@{}] serializeDevice:self.deviceMock2];
    
    // Test
    const char *devices = LEGODeviceManager_allDevices();
    
    // Verify
    XCTAssertTrue(strlen(devices) > 0, @"Expected non-empty device list");
    [self.deviceManagerMock verify];
    [self.serializationMock verify];
}

#pragma mark Delegates/events

- (void)testDeviceDidAppear
{
    // Setup
    [self setupForDelegateCall:@"LEDeviceManagerDeviceDidAppear"];
    
    // Test
    [self.deviceManagerWrapper deviceManager:self.deviceManagerMock deviceDidAppear:self.deviceMock];
    
    // Verify
    [self verifyDelegateCall];
}

- (void)testDeviceDidDisappear
{
    // Setup
    [self setupForDelegateCall:@"LEDeviceManagerDeviceDidDisappear"];

    // Test
    [self.deviceManagerWrapper deviceManager:self.deviceManagerMock deviceDidDisappear:self.deviceMock];
    
    // Verify
    [self verifyDelegateCall];
}

- (void)testDeviceDisconnected
{
    // Setup
    [self setupForDelegateCall:@"LEDeviceManagerDidDisconnectFromDevice"];

    // Test
    [self.deviceManagerWrapper deviceManager:self.deviceManagerMock didDisconnectFromDevice:self.deviceMock willAttemptAutoReconnect:NO error:nil];
    
    // Verify
    [self verifyDelegateCall];
}

- (void)testFailedToConnectToDevice
{
    // Setup
    [self setupForDelegateCall:@"LEDeviceManagerDidFailToConnectToDevice"];
    
    // Test
    [self.deviceManagerWrapper deviceManager:self.deviceManagerMock didFailToConnectToDevice:self.deviceMock willAttemptAutoReconnect:NO error:nil];
    
    // Verify
    [self verifyDelegateCall];
}

- (void)testDidStartInterrogatingDevice
{
    // Setup
    [self setupForDelegateCall:@"LEDeviceManagerDidStartInterrogatingDevice"];
    
    // Test
    [self.deviceManagerWrapper deviceManager:self.deviceManagerMock didStartInterrogatingDevice:self.deviceMock];
    
    // Verify
    [self verifyDelegateCall];
}

- (void)testDidFinishInterrogatingDevice
{
    // Setup
    [self setupForDelegateCall:@"LEDeviceManagerDidFinishInterrogatingDevice"];
    
    // Test
    [self.deviceManagerWrapper deviceManager:self.deviceManagerMock didFinishInterrogatingDevice:self.deviceMock];
    
    // Verify
    [self verifyDelegateCall];
}

- (void)testWillStartConnectingToDevice
{
    // Setup
    [self setupForDelegateCall:@"LEDeviceManagerWillStartConnectingToDevice"];
    
    // Test
    [self.deviceManagerWrapper deviceManager:self.deviceManagerMock willStartConnectingToDevice:self.deviceMock];
    
    // Verify
    [self verifyDelegateCall];
}

@end
