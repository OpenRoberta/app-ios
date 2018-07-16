//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETiltSensor.h"
#import "LEService+Project.h"
#import "LELogger+Project.h"
#import "LEInputFormat.h"
#import "LEDataFormat.h"

#pragma mark - LETiltSensorAngle

LETiltSensorAngle LETiltSensorAngleMake(CGFloat x, CGFloat y) {
    LETiltSensorAngle angle;
    angle.x = x;
    angle.y = y;
    return angle;
}

BOOL LETiltSensorAngleEqualToAngle(LETiltSensorAngle angle1, LETiltSensorAngle angle2) {

    float acceptableDiff = 0.01;
    return (angle1.x - angle2.x < acceptableDiff && angle1.y - angle2.y < acceptableDiff);
}

const LETiltSensorAngle LETiltSensorAngleZero = { 0, 0 };


#pragma mark - LETiltSensorCrash

LETiltSensorCrash LETiltSensorCrashMake(uint8_t x, uint8_t y, uint8_t z) {
    LETiltSensorCrash crash;
    crash.x = x;
    crash.y = y;
    crash.z = z;
    return crash;
}

BOOL LETiltSensorCrashEqualToCrash(LETiltSensorCrash crash1, LETiltSensorCrash crash2) {
    return (crash1.x == crash2.x && crash1.y == crash2.y && crash1.z == crash2.z);
}

const LETiltSensorCrash LETiltSensorCrashZero = { 0, 0, 0 };


#pragma mark - LETiltSensor Class

@implementation LETiltSensor



- (instancetype)initWithConnectInfo:(LEConnectInfo *)connectInfo io:(LEIO *)io
{
    self = [super initWithConnectInfo:connectInfo io:io];
    if (self) {
        [self addValidDataFormats];

    }
    return self;
}


#pragma mark - Configuration of sensor
- (NSString *)serviceName
{
    return @"Tilt Sensor";
}

- (LEInputFormat *)defaultInputFormat
{
    return [LEInputFormat inputFormatWithConnectID:self.connectInfo.connectID typeID:self.connectInfo.type mode:LETiltSensorModeTilt deltaInterval:1 unit:LEInputFormatUnitSI notificationsEnabled:YES];
}

- (void)addValidDataFormats
{
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Angle" mode:LETiltSensorModeAngle unit:LEInputFormatUnitRaw sizeOfDataSet:sizeof(uint8_t) dataSetCount:2]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Angle" mode:LETiltSensorModeAngle unit:LEInputFormatUnitPercentage sizeOfDataSet:sizeof(uint8_t) dataSetCount:2]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Angle" mode:LETiltSensorModeAngle unit:LEInputFormatUnitSI sizeOfDataSet:sizeof(Float32) dataSetCount:2]];

    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Tilt" mode:LETiltSensorModeTilt unit:LEInputFormatUnitRaw sizeOfDataSet:sizeof(uint8_t) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Tilt" mode:LETiltSensorModeTilt unit:LEInputFormatUnitPercentage sizeOfDataSet:sizeof(uint8_t) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Tilt" mode:LETiltSensorModeTilt unit:LEInputFormatUnitSI sizeOfDataSet:sizeof(Float32) dataSetCount:1]];

    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Crash" mode:LETiltSensorModeCrash unit:LEInputFormatUnitRaw sizeOfDataSet:sizeof(uint8_t) dataSetCount:3]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Crash" mode:LETiltSensorModeCrash unit:LEInputFormatUnitPercentage sizeOfDataSet:sizeof(uint8_t) dataSetCount:3]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Crash" mode:LETiltSensorModeCrash unit:LEInputFormatUnitSI sizeOfDataSet:sizeof(Float32) dataSetCount:3]];
}


#pragma mark - Set new Input format
- (void)setTiltSensorMode:(LETiltSensorMode)tiltSensorMode
{
    [self updateCurrentInputFormatWithNewMode:tiltSensorMode];
}

- (LETiltSensorMode)tiltSensorMode {
    return [self inputFormatMode];
}


#pragma mark - Sensor values in different modes

- (LETiltSensorDirection)direction
{
    if (self.inputFormat.mode != LETiltSensorModeTilt) {
        return LETiltSensorDirectionUnknown;
    }


    uint8_t directionInt = (uint8_t) self.numberFromValueData.integerValue;
    if (directionInt <= 10) {
        return (LETiltSensorDirection) directionInt;
    } else {
        return LETiltSensorDirectionUnknown;
    }

}

- (LETiltSensorAngle)angle
{
    if (self.inputFormat.mode != LETiltSensorModeAngle) {
        return LETiltSensorAngleZero;
    }

    NSArray *dataSetNumbers = self.numbersFromValueDataSet;
    if (dataSetNumbers.count == 2) {
        return LETiltSensorAngleMake([self floatFromNumber:dataSetNumbers[0]], [self floatFromNumber:dataSetNumbers[1]]);
    }
    return LETiltSensorAngleZero;
}

- (LETiltSensorCrash)crash
{
    if (self.inputFormat.mode != LETiltSensorModeCrash) {
        return LETiltSensorCrashZero;
    }

    NSArray *dataSetNumbers = self.numbersFromValueDataSet;
    if (dataSetNumbers.count == 3) {
        return LETiltSensorCrashMake([self integerFromNumber:dataSetNumbers[0]], [self integerFromNumber:dataSetNumbers[1]], [self integerFromNumber:dataSetNumbers[2]]);
    }
    return LETiltSensorCrashZero;
}

- (uint8_t)integerFromNumber:(NSNumber *)number
{
    return (uint8_t) number.integerValue;
}

- (CGFloat)floatFromNumber:(NSNumber *)number
{
    return (CGFloat) number.floatValue;
}


#pragma mark - Handle Updated Values and Input Formats

- (BOOL)handleUpdatedValueData:(NSData *)valueData error:(NSError **)error
{
    //Remember the old values before calling 'handleUpdatedValueData'
    LETiltSensorDirection oldDirection = self.direction;
    LETiltSensorAngle oldAngle = self.angle;
    LETiltSensorCrash oldCrash = self.crash;

    BOOL success = [super handleUpdatedValueData:valueData error:error];

    if (success) {
        __weak __typeof__(self) weakSelf = self;
        [self.delegates foreach:^(id delegate, BOOL *stop) {
            if (self.tiltSensorMode == LETiltSensorModeTilt && [delegate respondsToSelector:@selector(tiltSensor:didUpdateDirectionFrom:to:)]) {
                [delegate tiltSensor:weakSelf didUpdateDirectionFrom:oldDirection to:self.direction];
            } else if (self.tiltSensorMode == LETiltSensorModeAngle && [delegate respondsToSelector:@selector(tiltSensor:didUpdateAngleFrom:to:)]) {
                [delegate tiltSensor:weakSelf didUpdateAngleFrom:oldAngle to:self.angle];
            } else if (self.tiltSensorMode == LETiltSensorModeCrash && [delegate respondsToSelector:@selector(tiltSensor:didUpdateCrashFrom:to:)]) {
                [delegate tiltSensor:weakSelf didUpdateCrashFrom:oldCrash to:self.crash];
            }
        }];
    }

    return success;
}

#pragma mark - KVO compliance

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"direction"]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"inputFormat.mode", @"numberFromValueData"]];
    } else if ([@[@"angle", @"crash"] containsObject:key]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"inputFormat.mode", @"numbersFromValueDataSet"]];
    }
    return keyPaths;
}

@end