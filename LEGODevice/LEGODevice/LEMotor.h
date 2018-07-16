#import "LEService.h"

//
// Created by Søren Toft Odgaard on 8/14/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//
@class LEMotor;
@class LEConnectInfo;

static const NSUInteger LEMotorMinSpeed = 1;
static const NSUInteger LEMotorMaxSpeed = 100;

/** The direction of a motor */
typedef NS_ENUM(NSInteger, LEMotorDirection) {
    /** Drifting (Floating) */
    LEMotorDirectionDrifting = 0,
    /** Running left */
    LEMotorDirectionLeft = 1,
    /** Running right */
    LEMotorDirectionRight = 2,
    /** Brake */
    LEMotorDirectionBraking = 3
};

/**
 This service allows for controlling a simple motor
*/
@interface LEMotor : LEService

/**
 The power the motor is currently running with (0 if braking of drifting).
*/
@property (readonly) NSUInteger power;

/**
 The current running direction of the motor
*/
@property (readonly) LEMotorDirection direction;

/**
 YES if the motor is currently braking (not running)
*/
@property (readonly) BOOL isBraking;

/**
 YES if the motor is currently drifting / floating.
 When floating the motor axis can be turned without resistance.
*/
@property (readonly) BOOL isDrifting;

/**
 Send a command to run the motor at a given power in a given direction.
 The minimum speed is 0 and the maximum speed is 100.

 @param direction   The direction to run the motor
 @param power       The power to run the motor with.
*/
- (void)runInDirection:(LEMotorDirection)direction power:(NSUInteger)power;

/**
 Send a command to stop (brake) the motor
*/
- (void)brake;

/**
 Send a command to stop (drift/float) the motor
*/
- (void)drift;



@end