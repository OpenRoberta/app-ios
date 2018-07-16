//
// Created by Søren Toft Odgaard on 8/14/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LEService+Project.h"
#import "LEMotor.h"
#import "LELogger+Project.h"
#import "LEDevice.h"

static const NSUInteger LEMotorPowerDrift = 0;
static const NSUInteger LEMotorPowerBrake = 127;

//Only send values in the range 35-100.
//An offset is needed as values below 35 is not enough power to actually make
//the motor turn.
static const NSUInteger MotorPowerOffset = 35;

@interface LEMotor ()

@property (nonatomic) int8_t mostRecentSendPower;
@property (readwrite) LEMotorDirection direction;

@end

@implementation LEMotor

- (NSString *)serviceName
{
    return @"Motor";
}



- (void)runInDirection:(LEMotorDirection)direction power:(NSUInteger)power
{
    if (power == LEMotorPowerDrift) {
        [self drift];
    } else {
        [self sendPower:[self convertUnsignedMotorPowerToSigned:power direction:direction]];
        self.direction =  direction;
    }
}

- (void)brake
{
    [self sendPower:LEMotorPowerBrake];
    self.direction = LEMotorDirectionBraking;
}

- (void)drift
{
    [self sendPower:LEMotorPowerDrift];
    self.direction = LEMotorDirectionDrifting;
}


- (BOOL)isBraking
{
    return (self.mostRecentSendPower == LEMotorPowerBrake);
}

- (BOOL)isDrifting
{
    return (self.mostRecentSendPower == LEMotorPowerDrift);
}

- (NSUInteger)power
{
    if (self.mostRecentSendPower == LEMotorPowerBrake || self.mostRecentSendPower == LEMotorPowerDrift) {
        return 0;
    }
    return (NSUInteger) abs(self.mostRecentSendPower);
}


- (void)sendPower:(int8_t)power
{
    LEDebugLog(@"Setting motor power %ld for connectID %i", (long) power, self.connectInfo.connectID);
   
    if (power == LEMotorPowerBrake || power == LEMotorPowerDrift) {
        //Brake and Float should not be affected byt the offset
        [self.io writeMotorPower:power forConnectID:self.connectInfo.connectID];
    } else {
        int8_t offset = MotorPowerOffset;
        if (self.device.deviceInfo.firmwareRevision.majorVersion == 0) {
            //On version 0.x of the firmware, PVM offset is handled in the firmware
            offset = 0;
        }        
        [self.io writeMotorPower:power offset:offset forConnectID:self.connectInfo.connectID];
    };
    self.mostRecentSendPower  = power;

    NSError *error;
    [self handleUpdatedValueData:[NSData dataWithBytes:&_mostRecentSendPower length:sizeof(_mostRecentSendPower)] error:&error];
    if (error) {
        LEErrorLog(@"%@", error.localizedDescription);
    }
}


- (int8_t)convertUnsignedMotorPowerToSigned:(NSUInteger)power direction:(LEMotorDirection)direction
{
    int8_t resultPower = (int8_t) ((power < LEMotorMaxSpeed) ? power : LEMotorMaxSpeed);

    if (direction == LEMotorDirectionLeft) {
        resultPower = -resultPower;
    }

    return resultPower;
}

#pragma mark - KVO compliance

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([@[@"braking", @"drifting", @"power"] containsObject:key]) {
        keyPaths = [keyPaths setByAddingObject:@"mostRecentSendPower"];
    }
    return keyPaths;
}

@end