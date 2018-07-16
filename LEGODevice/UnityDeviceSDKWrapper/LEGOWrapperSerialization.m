//
//  WrapperSerialization.m
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 27/03/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import "LEGOWrapperSerialization.h"
#import "LEDevice.h"
#import "LEDeviceInfo.h"
#import "LEService+Project.h"
#import "LEInputFormat.h"
#import "LEMotor.h"
#import "LERGBLight.h"
#import "LEMotionSensor.h"
#import "LETiltSensor.h"
#import "LEVoltageSensor.h"
#import "LECurrentSensor.h"
#import "LEPiezoTonePlayer.h"

@implementation LEGOWrapperSerialization

#pragma mark - Device

+ (NSDictionary *)serializeDevice:(LEDevice *)leDevice
{
    NSDictionary *deviceInfo = @{ @"FirmwareRevision" : (leDevice.deviceInfo.firmwareRevision != nil ? [leDevice.deviceInfo.firmwareRevision stringRepresentation] : @""),
                                  @"HardwareRevision" : (leDevice.deviceInfo.hardwareRevision != nil ? [leDevice.deviceInfo.hardwareRevision stringRepresentation] : @""),
                                  @"SoftwareRevision" : (leDevice.deviceInfo.softwareRevision != nil ? [leDevice.deviceInfo.softwareRevision stringRepresentation] : @""),
                                  @"ManufacturerName" : (leDevice.deviceInfo.manufacturerName != nil ? leDevice.deviceInfo.manufacturerName : @"") };

    NSDictionary *device = @{ @"DeviceName"             : leDevice.name ?: @"",
                              @"DeviceID"               : leDevice.deviceId,
                              @"DeviceInfo"             : deviceInfo,
                              @"ButtonPressed"          : @(leDevice.isButtonPressed),
                              @"BatteryLevel"           : leDevice.batteryLevel ?: @0,
                              @"ConnectedState"         : @(leDevice.connectState),
                              @"Category"               : @(leDevice.category),
                              @"SupportedFunctions"     : @(leDevice.supportedFunctions),
                              @"LastConnectedNetworkId" : @(leDevice.lastConnectedNetworkId) };
    
    return device;
}

+ (NSArray *)serializeDevices:(NSArray *)devices
{
    NSMutableArray *serializedDevices = [NSMutableArray new];
    for (LEDevice *device in devices) {
        [serializedDevices addObject:[self serializeDevice:device]];
    }
    return serializedDevices;
}

#pragma mark - Device events

+ (NSDictionary *)serializeDevice:(LEDevice *)device nameChangeFrom:(NSString *)oldName to:(NSString *)newName
{
    return @{ @"DeviceID"      : device.deviceId,
              @"OldDeviceName" : oldName ?: @"",
              @"DeviceName"    : newName ?: @"" };
}

+ (NSDictionary *)serializeDevice:(LEDevice *)device buttonStateChange:(BOOL)pressed
{
    return @{ @"DeviceID"    : device.deviceId,
              @"ButtonState" : @(pressed) };
}

+ (NSDictionary *)serializeDevice:(LEDevice *)device batteryLevel:(NSInteger)level
{
    return @{ @"DeviceID"     : device.deviceId,
              @"BatteryLevel" : @(level) };
}

+ (NSDictionary *)serializeDevice:(LEDevice *)device lowVoltage:(BOOL)lowVoltage
{
    return @{ @"DeviceID"     : device.deviceId,
              @"LowVoltageState" : @(lowVoltage) };
}


+ (NSDictionary *)serializeDevice:(LEDevice *)device error:(NSError *)error
{
    return @{ @"DeviceID" : device.deviceId,
              @"Error"    : error.localizedDescription ?: @"" };
}

#pragma mark - Input format

+ (NSDictionary *)serializeInputFormat:(LEInputFormat *)inputFormat
{
    if (inputFormat == nil) {
        return @{};
    }
    
    return @{ @"Revision"             : @(inputFormat.revision),
              @"ConnectID"            : @(inputFormat.connectID),
              @"TypeID"               : @(inputFormat.typeID),
              @"Mode"                 : @(inputFormat.mode),
              @"DeltaInterval"        : @(inputFormat.deltaInterval),
              @"Unit"                 : @(inputFormat.unit),
              @"NotificationsEnabled" : @(inputFormat.notificationsEnabled) };
}

#pragma mark - Service

+ (NSDictionary *)serializeService:(LEService *)service
{
    return [self serializeService:service onlyBasicInfo:NO];
}

+ (NSDictionary *)serializeService:(LEService *)service onlyBasicInfo:(BOOL)onlyBasicInfo
{
    if (onlyBasicInfo) {
        return @{ @"DeviceID"  : service.device.deviceId,
                  @"ConnectID" : @(service.connectInfo.connectID) };
    } else {
        NSDictionary *connectInfo = @{ @"ConnectID"        : @(service.connectInfo.connectID),
                                       @"HubIndex"         : @(service.connectInfo.hubIndex),
                                       @"HardwareRevision" : service.connectInfo.hardwareVersion != nil ? [service.connectInfo.hardwareVersion stringRepresentation] : @"",
                                       @"SoftwareRevision" : service.connectInfo.firmwareVersion != nil ? [service.connectInfo.firmwareVersion stringRepresentation] : @"",
                                       @"Type"             : @(service.connectInfo.type) };
        
        return @{ @"ServiceName"        : service.serviceName ?: @"",
                  @"DefaultInputFormat" : [self serializeInputFormat:service.defaultInputFormat],
                  @"InputFormat"        : [self serializeInputFormat:service.inputFormat],
                  @"IsInternalService"  : @(service.isInternalService),
                  @"ConnectInfo"        : connectInfo,
                  @"DeviceID"           : service.device.deviceId };
    }
}

+ (NSDictionary *)serializeServiceWithData:(LEService *)service
{
    NSMutableDictionary *serializedService = [[self serializeService:service] mutableCopy];
    NSDictionary *serviceData = [self serializeServiceData:service];
    if (serviceData != nil) {
        serializedService[@"ServiceData"] = serviceData;
    }
    return serializedService;
}

#pragma mark - Specific services

+ (NSDictionary *)serializeServiceData:(LEService *)service
{
    if ([service isKindOfClass:[LEMotor class]]) {
        return [self serializeMotorData:(LEMotor *)service];
    } else if ([service isKindOfClass:[LERGBLight class]]) {
        return [self serializeRGBLightData:(LERGBLight *)service];
    } else if ([service isKindOfClass:[LEMotionSensor class]]) {
        return [self serializeMotionSensorData:(LEMotionSensor *)service];
    } else if ([service isKindOfClass:[LETiltSensor class]]) {
        return [self serializeTiltSensorData:(LETiltSensor *)service];
    } else if ([service isKindOfClass:[LEVoltageSensor class]]) {
        return [self serializeVoltageSensorData:(LEVoltageSensor *)service];
    } else if ([service isKindOfClass:[LECurrentSensor class]]) {
        return [self serializeCurrentSensorData:(LECurrentSensor *)service];
    } else if ([service isKindOfClass:[LEPiezoTonePlayer class]]) {
        return [self serializePiezoTonePlayerData:(LEPiezoTonePlayer *)service];
    } else {
        // return no service data for unknown services
        return nil;
    }
}

+ (NSDictionary *)serializeMotorData:(LEMotor *)motor
{
    return @{ @"Power"          : @(motor.power),
              @"MotorDirection" : @(motor.direction) };
}

+ (NSDictionary *)serializeRGBLightData:(LERGBLight *)light
{
    return @{ @"RGBLightMode"      : @(light.rgbMode),
              @"Color"             : [self serializeColor:light.color],
              @"DefaultColor"      : [self serializeColor:light.defaultColor],
              @"ColorIndex"        : @(light.colorIndex),
              @"DefaultColorIndex" : @(light.defaultColorIndex) };
}

+ (NSDictionary *)serializeMotionSensorData:(LEMotionSensor *)motionSensor
{
    return  @{ @"Count"            : @(motionSensor.count),
               @"Distance"         : @(motionSensor.distance),
               @"MotionSensorMode" : @(motionSensor.motionSensorMode) };
}

+ (NSDictionary *)serializeTiltSensorData:(LETiltSensor *)tiltSensor
{
    NSDictionary *angleDict = @{ @"X" : @(tiltSensor.angle.x),
                                 @"Y" : @(tiltSensor.angle.y) };
    
    NSDictionary *crashDict = @{ @"X" : @(tiltSensor.crash.x),
                                 @"Y" : @(tiltSensor.crash.y),
                                 @"Z" : @(tiltSensor.crash.z) };
    
    return @{ @"TiltSensorDirection" : @(tiltSensor.direction),
              @"TiltSensorMode"      : @(tiltSensor.tiltSensorMode),
              @"Angle"               : angleDict,
              @"Crash"               : crashDict };
}

+ (NSDictionary *)serializeVoltageSensorData:(LEVoltageSensor *)voltageSensor
{
    return @{ @"MilliVolts" : @(voltageSensor.milliVolts) };
}

+ (NSDictionary *)serializeCurrentSensorData:(LECurrentSensor *)currentSensor
{
    return @{ @"MilliAmp" : @(currentSensor.milliAmp) };
}

+ (NSDictionary *)serializePiezoTonePlayerData:(LEPiezoTonePlayer *)piezoTonePlayer
{
    // intentionally return no data for the piezo player
    return nil;
}

#pragma mark - Service events

+ (NSDictionary *)serializeService:(LEService *)service valueDataChangeFrom:(NSData *)oldValueData to:(NSData *)newValueData
{
    //TODO: Take size of data set into account
    
    NSMutableDictionary *data = [[self serializeService:service onlyBasicInfo:YES] mutableCopy];
    if (service.inputFormat.unit == LEInputFormatUnitPercentage || service.inputFormat.unit == LEInputFormatUnitRaw) {
        data[@"OldValue"] = @([service integerFromData:oldValueData]);
        data[@"NewValue"] = @([service integerFromData:newValueData]);
    } else if (service.inputFormat.unit == LEInputFormatUnitSI) {
        data[@"OldValue"] = @([service floatFromData:oldValueData]);
        data[@"NewValue"] = @([service floatFromData:newValueData]);
    } else {
        NSLog(@"Cannot serialize value with unkown input format unit");
    }
    
    return data;
}

+ (NSDictionary *)serializeService:(LEService *)service inputFormatChangeFrom:(LEInputFormat *)oldInputFormat to:(LEInputFormat *)newInputFormat
{
    NSMutableDictionary *data = [[self serializeService:service onlyBasicInfo:YES] mutableCopy];
    data[@"OldInputFormat"] = [self serializeInputFormat:oldInputFormat];
    data[@"NewInputFormat"] = [self serializeInputFormat:newInputFormat];
    
    return data;
}

+ (NSDictionary *)serializeMotionSensor:(LEMotionSensor *)motionSensor distanceChangeFrom:(CGFloat)oldDistance to:(CGFloat)newDistance
{
    NSMutableDictionary *data = [[self serializeService:motionSensor onlyBasicInfo:YES] mutableCopy];
    data[@"OldDistance"] = @(oldDistance);
    data[@"NewDistance"] = @(newDistance);
    
    return data;
}

+ (NSDictionary *)serializeMotionSensor:(LEMotionSensor *)motionSensor countChangeTo:(NSUInteger)count
{
    NSMutableDictionary *data = [[self serializeService:motionSensor onlyBasicInfo:YES] mutableCopy];
    data[@"Count"] = @(count);
    
    return data;
}

+ (NSDictionary *)serializeRGBLight:(LERGBLight *)light colorChangeFrom:(CIColor *)oldColor to:(CIColor *)newColor
{
    NSMutableDictionary *data = [[self serializeService:light onlyBasicInfo:YES] mutableCopy];
    data[@"OldColor"] = [self serializeColor:oldColor];
    data[@"NewColor"] = [self serializeColor:newColor];
    
    return data;
}

+ (NSDictionary *)serializeRGBLightIndex:(LERGBLight *)light colorChangeFromIndex:(NSUInteger)oldIndex to:(NSUInteger)newIndex
{
    NSMutableDictionary *data = [[self serializeService:light onlyBasicInfo:YES] mutableCopy];
    data[@"OldColorIndex"] = @(oldIndex);
    data[@"NewColorIndex"] = @(newIndex);
    
    return data;
}


+ (NSDictionary *)serializeTiltSensor:(LETiltSensor *)tiltSensor directionChangeFrom:(LETiltSensorDirection)oldDirection to:(LETiltSensorDirection)newDirection
{
    NSMutableDictionary *data = [[self serializeService:tiltSensor onlyBasicInfo:YES] mutableCopy];
    data[@"OldDirection"] = @(oldDirection);
    data[@"NewDirection"] = @(newDirection);
    
    return data;
}

+ (NSDictionary *)serializeTiltSensor:(LETiltSensor *)tiltSensor angleChangeFrom:(LETiltSensorAngle)oldAngle to:(LETiltSensorAngle)newAngle
{
    NSMutableDictionary *data = [[self serializeService:tiltSensor onlyBasicInfo:YES] mutableCopy];
    data[@"OldAngle"] = @{ @"X" : @(oldAngle.x),
                           @"Y" : @(oldAngle.y) };
    data[@"NewAngle"] = @{ @"X" : @(newAngle.x),
                           @"Y" : @(newAngle.y) };
    
    return data;
}

+ (NSDictionary *)serializeTiltSensor:(LETiltSensor *)tiltSensor crashChangeFrom:(LETiltSensorCrash)oldCrash to:(LETiltSensorCrash)newCrash
{
    NSMutableDictionary *data = [[self serializeService:tiltSensor onlyBasicInfo:YES] mutableCopy];
    data[@"OldCrash"] = @{ @"X" : @(oldCrash.x),
                           @"Y" : @(oldCrash.y),
                           @"Z" : @(oldCrash.z) };
    data[@"NewCrash"] = @{ @"X" : @(newCrash.x),
                           @"Y" : @(newCrash.y),
                           @"Z" : @(newCrash.z) };
    
    return data;
}

+ (NSDictionary *)serializeVoltageSensor:(LEVoltageSensor *)voltageSensor voltageChangeTo:(CGFloat)milliVolts
{
    NSMutableDictionary *data = [[self serializeService:voltageSensor onlyBasicInfo:YES] mutableCopy];
    data[@"MilliVolts"] = @(milliVolts);
    
    return data;
}

+ (NSDictionary *)serializeCurrentSensor:(LECurrentSensor *)currentSensor currentChangeTo:(CGFloat)milliAmp
{
    NSMutableDictionary *data = [[self serializeService:currentSensor onlyBasicInfo:YES] mutableCopy];
    data[@"MilliAmp"] = @(milliAmp);
    
    return data;
}

#pragma mark - Helpers

+ (NSDictionary *)serializeColor:(CIColor *)color
{
    return @{ @"R" : @(color.red),
              @"G" : @(color.green),
              @"B" : @(color.blue),
              @"A" : @(color.alpha) };
}

+ (CIColor *)deserializeColor:(NSDictionary *)color
{
    if (![color[@"R"] isKindOfClass:[NSNumber class]] ||
        ![color[@"G"] isKindOfClass:[NSNumber class]] ||
        ![color[@"B"] isKindOfClass:[NSNumber class]] ||
        ![color[@"A"] isKindOfClass:[NSNumber class]]) {
        return nil;
    }
    
    return [CIColor colorWithRed:[color[@"R"] floatValue]
                           green:[color[@"G"] floatValue]
                            blue:[color[@"B"] floatValue]
                           alpha:[color[@"A"] floatValue]];
}

#pragma mark - JSON serialization

+ (NSString *)stringFromJSONObject:(id)jsonObject
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if (jsonData == nil) {
        NSLog(@"Failed to encode object as JSON string: %@", [error description]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (id)objectFromJSONString:(NSString *)jsonString
{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                    options:0
                                                      error:&error];
    if (jsonObject == nil) {
        NSLog(@"Failed to decode JSON object from string: %@", [error description]);
        return nil;
    }
    
    return jsonObject;
}

@end
