//
//  LEGODeviceUnityWrapper.m
//  Unity-iPhone
//
//  Created by Kim Jung Nissen on 10/09/14.
//
//

#import "LEGODeviceManagerUnityWrapper.h"
#import "LEGODeviceUnityWrapper.h"
#import "LEGOWrapperUtils.h"
#import "LEGOUnityInvoker.h"
#import "LEGOWrapperSerialization.h"
#import "LELogger+Project.h"
#import "UnityCallbacks.h"

@implementation LEGODeviceManagerUnityWrapper

+ (instancetype)sharedInstance
{
    static LEGODeviceManagerUnityWrapper *wrapper;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[LEGODeviceManagerUnityWrapper alloc] init];
    });

    return wrapper;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[LEDeviceManager sharedDeviceManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    [[LEDeviceManager sharedDeviceManager] removeDelegate:self];
}

#pragma mark - Wrapper methods

- (void)scan
{
    [[LEDeviceManager sharedDeviceManager] scan];
}

- (void)stopScanning
{
    [[LEDeviceManager sharedDeviceManager] stopScanning];
}

- (void)connectToDevice:(NSString *)legoDeviceID
{
    LEDevice *legoDevice = [self deviceWithDeviceID:legoDeviceID];
    if (legoDevice != nil) {
        [[LEDeviceManager sharedDeviceManager] connectToDevice:legoDevice];
    }
}

- (void)disconnectDevice:(NSString *)legoDeviceID
{
    LEDevice *legoDevice = [self deviceWithDeviceID:legoDeviceID];
    if (legoDevice != nil) {
        [[LEDeviceManager sharedDeviceManager] cancelDeviceConnection:legoDevice];
    }
}

- (NSString *)allDevices
{
    NSArray *serializedDevices = [LEGOWrapperSerialization serializeDevices:[LEDeviceManager sharedDeviceManager].allDevices];
    return [LEGOWrapperSerialization stringFromJSONObject:serializedDevices];
}

#pragma mark - Helpers

- (LEDevice *)deviceWithDeviceID:(NSString *)legoDeviceID
{
    for (LEDevice *device in [LEDeviceManager sharedDeviceManager].allDevices) {
        if ([device.deviceId isEqualToString:legoDeviceID]) {
            return device;
        }
    }
    
    LEWarnLog(@"Device not found: %@", legoDeviceID);
    return nil;
}

- (LEService *)serviceWithDeviceID:(NSString *)legoDeviceID connectID:(NSString *)connectID
{
    LEDevice *leDevice = [self deviceWithDeviceID:legoDeviceID];
    if (leDevice == nil) {
        return nil;
    }

    for (LEService *service in leDevice.services) {
        if (service.connectInfo.connectID == [connectID integerValue]) {
            return service;
        }
    }
    
    LEWarnLog(@"Service not found for device %@: %@", legoDeviceID, connectID);
    return nil;
}

#pragma mark - LEDeviceManagerDelegate

- (void)deviceManager:(LEDeviceManager *)manager deviceDidAppear:(LEDevice *)device
{
    [device addDelegate:[LEGODeviceUnityWrapper sharedInstance]];
    [self invokeUnityMethod:LEDeviceManagerDeviceDidAppear withDevice:device];
}

- (void)deviceManager:(LEDeviceManager *)manager deviceDidDisappear:(LEDevice *)device
{
    [device removeDelegate:[LEGODeviceUnityWrapper sharedInstance]];
    [self invokeUnityMethod:LEDeviceManagerDeviceDidDisappear withDevice:device];
}

- (void)deviceManager:(LEDeviceManager *)manager didDisconnectFromDevice:(LEDevice *)device willAttemptAutoReconnect:(BOOL)autoReconnect error:(NSError *)error
{
    [self invokeUnityMethod:LEDeviceManagerDidDisconnectFromDevice withDevice:device];
}

- (void)deviceManager:(LEDeviceManager *)manager didFailToConnectToDevice:(LEDevice *)device willAttemptAutoReconnect:(BOOL)autoReconnect error:(NSError *)error
{
    [self invokeUnityMethod:LEDeviceManagerDidFailToConnectToDevice withDevice:device];
}

- (void)deviceManager:(LEDeviceManager *)manager didFinishInterrogatingDevice:(LEDevice *)device
{
    [self invokeUnityMethod:LEDeviceManagerDidFinishInterrogatingDevice withDevice:device];
}

- (void)deviceManager:(LEDeviceManager *)manager didStartInterrogatingDevice:(LEDevice *)device
{
    [self invokeUnityMethod:LEDeviceManagerDidStartInterrogatingDevice withDevice:device];
}

- (void)deviceManager:(LEDeviceManager *)manager willStartConnectingToDevice:(LEDevice *)device
{
    [self invokeUnityMethod:LEDeviceManagerWillStartConnectingToDevice withDevice:device];
}

- (void)invokeUnityMethod:(NSString *)methodName withDevice:(LEDevice *)device
{
    [LEGOUnityInvoker invokeMethod:methodName withData:[LEGOWrapperSerialization serializeDevice:device]];
}

@end

#pragma mark - Methods called from Unity

void LEGODeviceManager_scan()
{
    [[LEGODeviceManagerUnityWrapper sharedInstance] scan];
}

void LEGODeviceManager_stopScanning()
{
    [[LEGODeviceManagerUnityWrapper sharedInstance] stopScanning];
}

void LEGODeviceManager_connectToDevice(const char *legoDeviceID)
{
    [[LEGODeviceManagerUnityWrapper sharedInstance] connectToDevice:NSStringFromCString(legoDeviceID)];
}

void LEGODeviceManager_disconnectDevice(const char *legoDeviceID)
{
    [[LEGODeviceManagerUnityWrapper sharedInstance] disconnectDevice:NSStringFromCString(legoDeviceID)];
}

const char *LEGODeviceManager_allDevices()
{
    return LEGOMakeStringCopy(CStringFromNSString([[LEGODeviceManagerUnityWrapper sharedInstance] allDevices]));
}
