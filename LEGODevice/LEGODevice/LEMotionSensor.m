//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEMotionSensor.h"
#import "LEInputFormat+Project.h"
#import "LEService+Project.h"
#import "LEDataFormat.h"


@implementation LEMotionSensor

- (instancetype)initWithConnectInfo:(LEConnectInfo *)connectInfo io:(LEIO *)io
{
    if (self = [super initWithConnectInfo:connectInfo io:io]) {
        [self addValidDataFormats];
    }
    return self;
}

- (NSString *)serviceName
{
    return @"Motion Sensor";
}

- (LEInputFormat *)defaultInputFormat
{
    return [LEInputFormat inputFormatWithConnectID:self.connectInfo.connectID typeID:self.connectInfo.type mode:0 deltaInterval:1 unit:LEInputFormatUnitSI notificationsEnabled:YES];
}

- (void)addValidDataFormats
{
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Detect" mode:LEMotionSensorModeDetect unit:LEInputFormatUnitRaw sizeOfDataSet:sizeof(uint8_t) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Detect" mode:LEMotionSensorModeDetect unit:LEInputFormatUnitPercentage sizeOfDataSet:sizeof(uint8_t) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Detect" mode:LEMotionSensorModeDetect unit:LEInputFormatUnitSI sizeOfDataSet:sizeof(Float32) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Count" mode:LEMotionSensorModeCount unit:LEInputFormatUnitRaw sizeOfDataSet:sizeof(uint32_t) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Count" mode:LEMotionSensorModeCount unit:LEInputFormatUnitPercentage sizeOfDataSet:sizeof(uint8_t) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Count" mode:LEMotionSensorModeCount unit:LEInputFormatUnitSI sizeOfDataSet:sizeof(Float32) dataSetCount:1]];
}

- (void)setMotionSensorMode:(LEMotionSensorMode)motionSensorMode
{
    [self updateCurrentInputFormatWithNewMode:motionSensorMode];
}

- (LEMotionSensorMode)motionSensorMode
{
    return [self inputFormatMode];
}

- (CGFloat)distance
{
    if (self.motionSensorMode != LEMotionSensorModeDetect) {
        return 0;
    }

    return self.numberFromValueData.floatValue;
}


- (NSUInteger)count
{
    if (self.motionSensorMode != LEMotionSensorModeCount) {
        return 0;
    }

    return self.numberFromValueData.integerValue;
}


#pragma mark - Handle Updated Values and Input Formats

- (BOOL)handleUpdatedValueData:(NSData *)valueData error:(NSError **)error
{
    CGFloat oldDistance = self.distance;
    BOOL success = [super handleUpdatedValueData:valueData error:error];

    if (success) {
        __weak __typeof__(self) weakSelf = self;
        [self.delegates foreach:^(id delegate, BOOL *stop) {
            if (self.motionSensorMode == LEMotionSensorModeDetect && [delegate respondsToSelector:@selector(motionSensor:didUpdateDistanceFrom:to:)]) {
                [delegate motionSensor:weakSelf didUpdateDistanceFrom:oldDistance to:self.distance];
            } else if (self.motionSensorMode == LEMotionSensorModeCount && [delegate respondsToSelector:@selector(motionSensor:didUpdateCountTo:)]) {
                [delegate motionSensor:weakSelf didUpdateCountTo:self.count];
            }
        }];
    }

    return success;
}

- (void)handleUpdatedInputFormat:(LEInputFormat *)inputFormat
{
    [self willChangeValueForKey:@"motionSensorMode"];
    [super handleUpdatedInputFormat:inputFormat];
    [self didChangeValueForKey:@"motionSensorMode"];
}

#pragma mark - KVO compliance

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([@[@"distance", @"count"] containsObject:key]) {
        keyPaths = [keyPaths setByAddingObjectsFromArray:@[@"motionSensorMode", @"numberFromValueData"]];
    }
    return keyPaths;
}

@end