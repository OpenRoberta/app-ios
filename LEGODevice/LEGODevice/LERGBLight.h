//
// Created by Søren Toft Odgaard on 20/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEService.h"

@class LERGBLight;
@class CIColor;

//Subscribe to this notification to be notified when the first (initial) color of the RGB Light is read
extern NSString *const DID_RECEIVE_DEFAULT_COLOR_NOTIFICATION;

/**
 Implement this protocol to be notified when the LERGBLight updates its value
*/
@protocol LERGBLightDelegate <LEServiceDelegate>

@optional

/**
 Invoked when the LERGBLight service receives an updated value
 Will only be invoked when the RGB light is is mode LERGBModeAbsolute
 @param rgbLight    The RGB light
 @param oldColor    The previous color
 @param newColor    The new color
*/
- (void)rgbLight:(LERGBLight *)rgbLight didUpdateColorFrom:(CIColor *)oldColor to:(CIColor *)newColor;

/**
 Invoked when the LERGBLight service receives an updated color index
 Will only be invoked when the RGB light is is mode LERGBModeDiscrete
 @param rgbLight        The RGB light
 @param oldColorIndex   The previous color index
 @param newColorIndex   The new color index
*/
- (void)rgbLight:(LERGBLight *)rgbLight didUpdateColorIndexFrom:(NSUInteger)oldColorIndex to:(NSUInteger)newColorIndex;

@end



/**
 This service allows for setting the colour of the RGB light on the device
*/
@interface LERGBLight : LEService


/** The index of the Absolute mode */
@property (nonatomic, readonly) uint8_t absoluteModeIndex;

/** The index of the Discrete mode */
@property (nonatomic, readonly) uint8_t discreteModeIndex;


/** The current mode of the RGB */
@property (nonatomic, readwrite) uint8_t rgbMode;


/**
 Switch to the default Color (i.e. the same color as the device has right after a successful connection has been established)
*/
- (void)switchToDefaultColor;

/**
 The default color of the RGB, when in mode LERGBModeAbsolute
*/
@property (nonatomic, readonly) CIColor* defaultColor;

/**
 The default color index of the RGB, when in mode LERGBModeDiscrete
 */
@property (nonatomic, readonly) NSUInteger defaultColorIndex;

/**
 Switch off the RGB light on the device
*/
- (void)switchOff;


/** @name Mode LEModeAbsolute */

/**
 The color of the RGB light on the device.
*/
@property (nonatomic, strong) CIColor *color;
/**
 The old color of the RGB light on the device - needed in order for the color value to reflect the latest value
 */
@property (nonatomic, strong) CIColor *oldColor;



/** @name Mode LEModeDiscrete */

/**
 The index of the currently selected color
*/
@property (nonatomic, readwrite) NSUInteger colorIndex;
/**
 The old color index of the RGB light on the device - needed in order for the color index value to reflect the latest value
 */
@property (nonatomic, readwrite) NSUInteger oldColorIndex;


@end