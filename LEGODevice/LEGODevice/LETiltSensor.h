//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEService.h"

@class LETiltSensor;

/**
Direction of tilt sensor
*/
typedef NS_ENUM(uint8_t, LETiltSensorDirection) {
    /** Neutral */
    LETiltSensorDirectionNeutral = 0,
    /** Backward */
    LETiltSensorDirectionBackward = 3,
    /** Right */
    LETiltSensorDirectionRight = 5,
    /** Left */
    LETiltSensorDirectionLeft = 7,
    /** Forward */
    LETiltSensorDirectionForward = 9,
    /** Unknown */
    LETiltSensorDirectionUnknown = 10
};

/**
Tilt sensor mode
*/
typedef NS_ENUM(uint8_t, LETiltSensorMode) {
    /** Angle */
    LETiltSensorModeAngle = 0,
    /** Tilt */
    LETiltSensorModeTilt = 1,
    /** Crash */
    LETiltSensorModeCrash = 2,
    /** Unknown  */
    LETiltSensorModeUnknown
};

typedef struct {
    CGFloat x;
    CGFloat y;
} LETiltSensorAngle;

typedef struct {
    NSUInteger x;
    NSUInteger y;
    NSUInteger z;
} LETiltSensorCrash;


LETiltSensorAngle LETiltSensorAngleMake(CGFloat x, CGFloat y);

BOOL LETiltSensorAngleEqualToAngle(LETiltSensorAngle angle1, LETiltSensorAngle angle2);

extern const LETiltSensorAngle LETiltSensorAngleZero;

LETiltSensorCrash LETiltSensorCrashMake(uint8_t x, uint8_t y, uint8_t z);

BOOL LETiltSensorCrashEqualToCrash(LETiltSensorCrash crash1, LETiltSensorCrash crash2);

extern const LETiltSensorCrash LETiltSensorCrashZero;

/**
Implement this protocol to be notified when the LETiltSensor updates its value
*/
@protocol LETiltSensorDelegate <LEServiceDelegate>

@optional

/**
Invoked when the tilt sensor has an updated value for direction.
@param sensor          The tilt sensor
@param oldDirection    The previous direction
@param newDirection    The new direction
*/
- (void)tiltSensor:(LETiltSensor *)sensor didUpdateDirectionFrom:(LETiltSensorDirection)oldDirection to:(LETiltSensorDirection)newDirection;

/**
Invoked when the tilt sensor has an updated value for angle.
@param sensor          The tilt sensor
@param oldAngle        The old angle
@param newAngle        The new angle
*/
- (void)tiltSensor:(LETiltSensor *)sensor didUpdateAngleFrom:(LETiltSensorAngle)oldAngle to:(LETiltSensorAngle)newAngle;

/**
Invoked when the tilt sensor has an updated value for crash readings.
@param sensor          The tilt sensor
@param oldCrashValue   The previous value
@param newCrashValue   The new crash value
*/
- (void)tiltSensor:(LETiltSensor *)sensor didUpdateCrashFrom:(LETiltSensorCrash)oldCrashValue to:(LETiltSensorCrash)newCrashValue;

@end

/**
This service provides readings from a tilt sensor.

Add a instance of a LETiltSensorDelegate using addDelegate: to be notified when a service receives an updated value.
*/
@interface LETiltSensor : LEService

/**
The most recent direction reading from the sensor.

If no direction reading has been received, of if the sensor is not in mode LETiltSensorModeTilt
the value of this property will be LETiltSensorDirectionUnknown.
*/
@property (nonatomic, readonly) LETiltSensorDirection direction;

/**
The most recent angle reading from the sensor. The angle represents the angle the sensor is tilted in the x, y and z-direction.

If no angle reading has been received, of if the sensor is not in mode LETiltSensorModeAngle
the value of this property will be LETiltSensorAngleZero
*/
@property (nonatomic, readonly) LETiltSensorAngle angle;

/**
The most recent crash reading from the sensor. The value represents the number of times the sensor has been 'bumped' in
the x, y, and z-direction. The value can be reset by sending the [LEService sendResetStateRequest].

If no angle reading has been received, of if the sensor is not in mode LETiltSensorModeCrash
the value of this property will be LETiltSensorCrashZero
*/
@property (nonatomic, readonly) LETiltSensorCrash crash;

/** The current mode of the tilt sensor */
@property (nonatomic, readwrite) LETiltSensorMode tiltSensorMode;


@end