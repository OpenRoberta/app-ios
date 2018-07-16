//
//  LECurrentSensor.m
//  LEGODevice
//
//  Created by Jon Nørrelykke on 15/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "LECurrentSensor.h"
#import "LEInputFormat+Project.h"
#import "LELogger+Project.h"
#import "LEService+Project.h"
#import "LEIO.h"

@implementation LECurrentSensor

- (LEInputFormat *)defaultInputFormat
{
    return [LEInputFormat
            inputFormatWithConnectID:self.connectInfo.connectID
            typeID:self.connectInfo.type
            mode:0 //only one available mode for current sensor
            deltaInterval:30
            unit:LEInputFormatUnitSI
            notificationsEnabled:YES];
}

- (NSString *)serviceName
{
    return @"Current";
}

- (CGFloat)milliAmp
{
    if (self.inputFormat.mode == 0 && self.inputFormat.unit == LEInputFormatUnitSI) {
        return self.valueAsFloat;
    } else {
        LEWarnLog(@"Can only retrieve milliAmp from Current Sensor when sensor is in mode 0 (default) and uses SI units");
        return 0;
    }
}

#pragma mark - Handle Updated Values
- (BOOL)handleUpdatedValueData:(NSData *)valueData error:(NSError **)error
{
    BOOL success = [super handleUpdatedValueData:valueData error:error];
    if (success) {
        __weak __typeof__(self) weakSelf = self;
        [self.delegates foreach:^(id delegate, BOOL *stop) {
            if ([delegate respondsToSelector:@selector(currentSensor:didUpdateMilliAmp:)]) {
                [delegate currentSensor:weakSelf didUpdateMilliAmp:self.milliAmp];
            }
        }];
    }
    return success;
}

#pragma mark - KVO compliance

+ (NSSet *)keyPathsForValuesAffectingMilliAmp
{
    return [NSSet setWithObjects:@"inputFormat.mode", @"inputFormat.unit", @"valueAsFloat", nil];
}

@end
