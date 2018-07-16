//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEService.h"

@class LEMotionSensor;

/**
 Supported modes for the motion sensor
*/
typedef NS_ENUM(uint8_t, LEMotionSensorMode) {
    /** Detect mode - produces value that reflect the relative distance from the sensor to objects in front of it */
    LEMotionSensorModeDetect = 0,
    /** Count mode - produces values that reflect how many times the sensor has been activated */
    LEMotionSensorModeCount = 1,
    /** Unknown (unsupported) mode */
    LEMotionSensorModeUnknown
};

/**
 Implement this protocol to be notified when the LEMotionSensor updates its value
*/
@protocol LEMotionSensorDelegate <LEServiceDelegate>

@optional

/**
 Invoked when the motion sensor has an updated distance value
 @param sensor      The sensor that has a new value
 @param oldDistance The previous distance reading
 @param newDistance The new distance reading
*/
- (void)motionSensor:(LEMotionSensor *)sensor didUpdateDistanceFrom:(CGFloat)oldDistance to:(CGFloat)newDistance;

/**
 Invoked when the motion sensor has an updated count value
 @param sensor      The sensor that has a new value
 @param count       The new value
*/
- (void)motionSensor:(LEMotionSensor *)sensor didUpdateCountTo:(NSUInteger)count;

@end

/**
 This service provides readings from an motion sensor (aka. detect sensor).

 Add a instance of a LEMotionSensorDelegate using addDelegate: to be notified when a service receives an updated value.
*/
@interface LEMotionSensor : LEService

/** The most recent distance reading from the sensor */
@property (nonatomic, readonly) CGFloat distance;

/** The most recent count reading from the sensor */
@property (nonatomic, readonly) NSUInteger count;

/** The current mode of the motion sensor */
@property (nonatomic, readwrite) LEMotionSensorMode motionSensorMode;


@end