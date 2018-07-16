//
//  WrapperSerialization.h
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 27/03/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CIColor;

@class LEDevice;
@class LEInputFormat;
@class LEService;
@class LEMotor;
@class LERGBLight;
@class LEMotionSensor;
#import "LETiltSensor.h"
@class LECurrentSensor;
@class LEVoltageSensor;
@class LEPiezoTonePlayer;

@interface LEGOWrapperSerialization : NSObject

// Device
+ (NSDictionary *)serializeDevice:(LEDevice *)device;
+ (NSArray *)serializeDevices:(NSArray *)devices; // expects an NSArray of LEDevice instances

// Device events
+ (NSDictionary *)serializeDevice:(LEDevice *)device nameChangeFrom:(NSString *)oldName to:(NSString *)newName;
+ (NSDictionary *)serializeDevice:(LEDevice *)device buttonStateChange:(BOOL)pressed;
+ (NSDictionary *)serializeDevice:(LEDevice *)device batteryLevel:(NSInteger)level;
+ (NSDictionary *)serializeDevice:(LEDevice *)device error:(NSError *)error;

// Input format
+ (NSDictionary *)serializeInputFormat:(LEInputFormat *)inputFormat;

// Service
+ (NSDictionary *)serializeService:(LEService *)service;
+ (NSDictionary *)serializeService:(LEService *)service onlyBasicInfo:(BOOL)onlyBasicInfo;
+ (NSDictionary *)serializeServiceWithData:(LEService *)service;

// Service events
+ (NSDictionary *)serializeService:(LEService *)service valueDataChangeFrom:(NSData *)oldValueData to:(NSData *)newValueData;
+ (NSDictionary *)serializeService:(LEService *)service inputFormatChangeFrom:(LEInputFormat *)oldInputFormat to:(LEInputFormat *)newInputFormat;
+ (NSDictionary *)serializeMotionSensor:(LEMotionSensor *)motionSensor distanceChangeFrom:(CGFloat)oldDistance to:(CGFloat)newDistance;
+ (NSDictionary *)serializeMotionSensor:(LEMotionSensor *)motionSensor countChangeTo:(NSUInteger)count;
+ (NSDictionary *)serializeRGBLight:(LERGBLight *)light colorChangeFrom:(CIColor *)oldColor to:(CIColor *)newColor;
+ (NSDictionary *)serializeRGBLightIndex:(LERGBLight *)light colorChangeFromIndex:(NSUInteger)oldIndex to:(NSUInteger)newIndex;
+ (NSDictionary *)serializeDevice:(LEDevice *)device lowVoltage:(BOOL)lowVoltage;
+ (NSDictionary *)serializeTiltSensor:(LETiltSensor *)tiltSensor directionChangeFrom:(LETiltSensorDirection)oldDirection to:(LETiltSensorDirection)newDirection;
+ (NSDictionary *)serializeTiltSensor:(LETiltSensor *)tiltSensor angleChangeFrom:(LETiltSensorAngle)oldAngle to:(LETiltSensorAngle)newAngle;
+ (NSDictionary *)serializeTiltSensor:(LETiltSensor *)tiltSensor crashChangeFrom:(LETiltSensorCrash)oldCrash to:(LETiltSensorCrash)newCrash;
+ (NSDictionary *)serializeVoltageSensor:(LEVoltageSensor *)voltageSensor voltageChangeTo:(CGFloat)milliVolts;
+ (NSDictionary *)serializeCurrentSensor:(LECurrentSensor *)currentSensor currentChangeTo:(CGFloat)milliAmp;

// Helpers
+ (NSDictionary *)serializeColor:(CIColor *)color;
+ (CIColor *)deserializeColor:(NSDictionary *)color;

// JSON serialization
+ (NSString *)stringFromJSONObject:(id)jsonObject;
+ (id)objectFromJSONString:(NSString *)jsonString;

@end
