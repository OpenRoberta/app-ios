//
//  LEVoltageSensor.h
//  LEGODevice
//
//  Created by Jon Nørrelykke on 15/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "LEService.h"

@class LEVoltageSensor;

/**
Implement this protocol to be notified when the LEVoltageSensor updates its value
*/
@protocol LEVoltageSensorDelegate <LEServiceDelegate>

/**
Invoked when the LEVoltageSensor receives an updated value
@param sensor      The sensor that has a new value
@param milliVolts  The new voltage value in milli volts
*/
- (void)voltageSensor:(LEVoltageSensor *)sensor didUpdateMilliVolts:(CGFloat)milliVolts;

@end

/**
This service provides voltage (milliVolts) readings for the battery on the device.
Add a instance of a LEVoltageSensorDelegate using addDelegate: to be notified when a service receives an updated value.
*/
@interface LEVoltageSensor : LEService

/**
The battery voltage in milli volts
*/
@property (nonatomic, readonly) CGFloat milliVolts;

@end
