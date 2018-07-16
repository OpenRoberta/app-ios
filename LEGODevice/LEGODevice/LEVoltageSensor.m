//
//  LEVoltageSensor.m
//  LEGODevice
//
//  Created by Jon Nørrelykke on 15/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "LEVoltageSensor.h"
#import "LEInputFormat.h"
#import "LELogger+Project.h"
#import "LEService+Project.h"
#import "LEIO.h"

@implementation LEVoltageSensor

#pragma mark - Configuration of sensor
- (NSString *)serviceName
{
    return @"Voltage";
}

- (LEInputFormat *)defaultInputFormat
{
    //only one available mode for voltage sensor
    return [LEInputFormat inputFormatWithConnectID:self.connectInfo.connectID typeID:self.connectInfo.type mode:0 deltaInterval:30 unit:LEInputFormatUnitSI notificationsEnabled:YES];
}




#pragma mark - Sensor values
- (CGFloat)milliVolts
{
    if (self.inputFormat.mode == 0 && self.inputFormat.unit == LEInputFormatUnitSI) {
        return self.valueAsFloat;
    } else {
        LEWarnLog(@"Can only retrieve milliVolt from Voltage Sensor when sensor is in mode 0 and uses SI units");
        return 0;
    }
}

#pragma mark - Handle updated values
- (BOOL)handleUpdatedValueData:(NSData *)valueData error:(NSError **)error
{
    BOOL success = [super handleUpdatedValueData:valueData error:error];

    if (success) {
        __weak __typeof__(self) weakSelf = self;
        [self.delegates foreach:^(id delegate, BOOL *stop) {
            if ([delegate respondsToSelector:@selector(voltageSensor:didUpdateMilliVolts:)]) {
                [delegate voltageSensor:weakSelf didUpdateMilliVolts:self.milliVolts];
            }
        }];
    }

    return success;
}

#pragma mark - KVO compliance

+ (NSSet *)keyPathsForValuesAffectingMilliVolts
{
    return [NSSet setWithObjects:@"inputFormat.mode", @"inputFormat.unit", @"valueAsFloat", nil];
}

@end
