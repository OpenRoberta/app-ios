//
// Created by Søren Toft Odgaard on 22/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEConnectInfo;

/** The input format unit */
typedef NS_ENUM(uint8_t, LEInputFormatUnit) {
    /** Raw */
    LEInputFormatUnitRaw = 0,
    /** Percentage */
    LEInputFormatUnitPercentage = 1,
    /** SI */
    LEInputFormatUnitSI = 2,
    /** Unknown */
    LEInputFormatUnitUnknown,
};

/**
This class represent a configuration of a Input (sensor). At any time a sensor can be in just one mode,
and the details of this mode is captured by this class.

For senors types recognized by the SDK (like the tilt and motion sensor) you will not need to know about
the details of this class as the implementation of these services in the SDK handles this for you.

If you need to access an Input that is not recognized by the SDK you will need to create and send
an input format for the corresponding service. See the LEGenericService documentation for an example.
*/
@interface LEInputFormat : NSObject


#pragma mark - Create a new LEInputFormat to be send to the device

/**
Create a new instance of an LEInputFormat.
@param connectID      The connectID of the service, see [LEService connectInfo].
@param typeID         The type of the IO, see [LEService connectInfo].
@param mode           The mode of the IO (Inputs/Senors may support a number of different modes)
@param deltaInterval  The delta interval
@param unit           The unit the sensor should return values in
@param notificationsEnabled  YES if the device should send updates when the value changes.
*/
+ (instancetype)inputFormatWithConnectID:(uint8_t)connectID
                                  typeID:(uint8_t)typeID
                                    mode:(uint8_t)mode
                           deltaInterval:(uint32_t)deltaInterval
                                    unit:(LEInputFormatUnit)unit
                    notificationsEnabled:(BOOL)notificationsEnabled;


/**
Creates a copy of this input format with a new mode
@param mode     The new mode
*/
- (instancetype)inputFormatBySettingMode:(uint8_t)mode;

/**
Creates a copy of this input format with a new mode and unit
@param mode     The new mode
@param unit     The new unit
*/
- (instancetype)inputFormatBySettingMode:(uint8_t)mode unit:(LEInputFormatUnit)unit;

/**
Creates a copy of this input format with a new delta interval
@param interval  The new delta interval
*/
- (instancetype)inputFormatBySettingDeltaInterval:(uint32_t)interval;

/**
Creates a copy of this input format with a new value for notifications enabled
@param enabled  YES if the sensor should send updates when the value changes
*/
- (instancetype)inputFormatBySettingNotificationsEnabled:(BOOL)enabled;


/** @name Check for equality */
/**
 Returns YES if this input format is equal to otherFormat
 @param otherFormat    The input format to be compared to the receiver.
*/
- (BOOL)isEqualToFormat:(LEInputFormat *)otherFormat;


/**
The revision of the Input Format (set by the Device).
When a new Input Format is set for a service the Device will send the updated Input Format through the [LEServiceDelegate service:didUpdateInputFormatFrom:to].
The Device will assign a revision number to the new Input Format. The revision number is matched against the revision format when receiving values for the
corresponding service.
*/
@property (nonatomic, readonly) uint8_t revision;

/** The connectID of the corresponding service, see [LEService connectInfo] */
@property (nonatomic, readonly) uint8_t connectID;

/** The typeID of the corresponding service, see [LEService connectInfo] */
@property (nonatomic, readonly) uint8_t typeID;

/** The mode of the Input  */
@property (nonatomic, readonly) uint8_t mode;

/** The delta interval. When notifications are enabled the service will only receive updates if the value has change with 'delta interval' or more since last reading */
@property (nonatomic, readonly) uint32_t deltaInterval;

/** The unit the values are delivered in (as raw values, or as SI values) */
@property (nonatomic, readonly) LEInputFormatUnit unit;

/** YES if new values are send whenever the value of the Input changes beyond delta interval */
@property (nonatomic, readonly, getter=isNotificationsEnabled) BOOL notificationsEnabled;

/** The number of bytes to be expected in the Input data payload (set by the Device) */
@property (nonatomic, readonly) uint8_t numberOfBytes;


@end