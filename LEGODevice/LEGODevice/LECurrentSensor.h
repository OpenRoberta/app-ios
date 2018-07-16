//
//  LECurrentSensor.h
//  LEGODevice
//
//  Created by Jon Nørrelykke on 15/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "LEService.h"

@class LECurrentSensor;

/**
 Implement this protocol to be notified when the LECurrentSensor updates its value
*/
@protocol LECurrentSensorDelegate <LEServiceDelegate>

/**
 Invoked when the LECurrentSensor receives an updated value
 @param sensor      The sensor that has a new value
 @param milliAmp    The new current value in milli amp
*/
- (void)currentSensor:(LECurrentSensor *)sensor didUpdateMilliAmp:(CGFloat)milliAmp;

@end

/**
 This service provides current (milliAmp) readings for the battery on the device.
 Add a instance of a LECurrentSensorDelegate using addDelegate: to be notified when a service receives an updated value.
*/
@interface LECurrentSensor : LEService

/**
 The battery current in milli amps
*/
@property (nonatomic, readonly) CGFloat milliAmp;

@end
