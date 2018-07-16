//
//  LEGODeviceUnityWrapper.m
//  Unity-iPhone
//
//  Created by Kim Jung Nissen on 18/09/14.
//
//

#import "LEGODeviceUnityWrapper.h"
#import "LEGODeviceManagerUnityWrapper.h"
#import "LEGOServiceUnityWrapper.h"
#import "LEGOWrapperUtils.h"
#import "LEGOWrapperSerialization.h"
#import "LEGOUnityInvoker.h"
#import "UnityCallbacks.h"

@implementation LEGODeviceUnityWrapper

+ (instancetype)sharedInstance
{
    static LEGODeviceUnityWrapper *wrapper;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[LEGODeviceUnityWrapper alloc] init];
    });

    return wrapper;
}

- (void)updateDeviceName:(NSString *)name forDeviceID:(NSString *)deviceId
{
    LEDevice *device = [[LEGODeviceManagerUnityWrapper sharedInstance] deviceWithDeviceID:deviceId];
    device.name = name;
}

#pragma mark - LEDeviceDelegate

- (void)device:(LEDevice *)device didAddService:(LEService *)service
{
    [service addDelegate:[LEGOServiceUnityWrapper sharedInstance]];
    [LEGOUnityInvoker invokeMethod:LEDeviceDidAddService withData:[LEGOWrapperSerialization serializeService:service]];
}

- (void)device:(LEDevice *)device didRemoveService:(LEService *)service
{
    [service removeDelegate:[LEGOServiceUnityWrapper sharedInstance]];
    [LEGOUnityInvoker invokeMethod:LEDeviceDidRemoveService withData:[LEGOWrapperSerialization serializeService:service onlyBasicInfo:YES]];
}

- (void)device:(LEDevice *)device didChangeButtonState:(BOOL)pressed
{
    [LEGOUnityInvoker invokeMethod:LEDeviceDidChangeButtonState withData:[LEGOWrapperSerialization serializeDevice:device buttonStateChange:pressed]];
}

- (void)device:(LEDevice *)device didChangeNameFrom:(NSString *)oldName to:(NSString *)newName
{
    [LEGOUnityInvoker invokeMethod:LEDeviceDidChangeName withData:[LEGOWrapperSerialization serializeDevice:device nameChangeFrom:oldName to:newName]];
}

- (void)device:(LEDevice *)device didFailToAddServiceWithError:(NSError *)error
{
    [LEGOUnityInvoker invokeMethod:LEDeviceDidFailToAddServiceWithError withData:[LEGOWrapperSerialization serializeDevice:device error:error]];
}

- (void)device:(LEDevice *)device didUpdateBatteryLevel:(NSNumber *)newLevel
{
    [LEGOUnityInvoker invokeMethod:LEDeviceDidUpdateBatteryLevel withData:[LEGOWrapperSerialization serializeDevice:device batteryLevel:newLevel.integerValue]];
}

- (void)device:(LEDevice *)device didUpdateLowVoltageState:(BOOL)lowVoltage
{
    [LEGOUnityInvoker invokeMethod:LEDeviceDidUpdateLowVoltageState withData:[LEGOWrapperSerialization serializeDevice:device lowVoltage:lowVoltage]];

}

- (void)device:(LEDevice *)device didUpdateDeviceInfo:(LEDeviceInfo *)deviceInfo error:(NSError *)error
{
    [LEGOUnityInvoker invokeMethod:LEDeviceDidUpdateDeviceInfo withData:[LEGOWrapperSerialization serializeDevice:device]];
}

@end

#pragma mark - Methods called from Unity

void LEGODevice_updateDeviceName(const char *legoDeviceID, const char *name)
{
    [[LEGODeviceUnityWrapper sharedInstance] updateDeviceName:NSStringFromCString(name)
                                                  forDeviceID:NSStringFromCString(legoDeviceID)];
}
