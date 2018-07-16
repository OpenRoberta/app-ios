//
// Created by Søren Toft Odgaard on 9/6/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "LEDeviceInfo.h"


@class LEDevice;
@class LEMultiDelegate;
@class LEService;


/**
The connect state of the Device
*/
typedef NS_ENUM(NSUInteger, LEDeviceState) {
    /** The Device is disconnected and no connection attempt is in progress */
            LEDeviceStateDisconnectedAdvertising,
    /** The Device is disconnected and no longer advertising - the device also returns to this state after a successful connection has been closed  */
            LEDeviceStateDisconnectedNotAdvertising,
    /** A connection attempt is in progress */
            LEDeviceStateConnecting,
    /** Connected and interrogating Device for required services */
            LEDeviceStateInterrogating,
    /** Connected and interrogation complete - device is ready for use */
            LEDeviceStateInterrogationFinished,
};

/**
 The Category of this Device
 */
typedef NS_ENUM(uint8_t, LEDeviceCategory) {
    /** WeDo  */
    LEDeviceCategoryWeDo       = 0,
    /** Duplo */
    LEDeviceCategoryDuplo      = 1,
    /** System */
    LEDeviceCategorySystem     = 2,
    /** Technic */
    LEDeviceCategoryTechnic    = 3,
    /** MINDSTORMS */
    LEDeviceCategoryMindStorms = 4,
    /** Unknown */
    LEDeviceCategoryUnknown    = 5
};

/**
 The Function a Device will support.
*/
typedef NS_OPTIONS(uint8_t, LEDeviceFunction) {
    /** Central Mode */
    LEDeviceFunctionCentralMode            = 0,
    /** Peripheral Mode */
    LEDeviceFunctionPeripheralMode         = 1,
    /** Device IO Ports mode */
    LEDeviceFunctionIOPorts                = 2,
    /** Device acts as a remocte controller */
    LEDeviceFunctionActsAsRemoteController = 3,
};


/**
Implement this protocol to be notified about changes to the attributes of the device.
The delegate will notify you when an IO such as a motor or sensor is attached or detached from the Device.
The delegate will also notify about changes to the device name, battery level and the connect-button state (pressed/released).
*/
@protocol LEDeviceDelegate <NSObject>

@optional

/** @name Monitoring changes to device attributes  */

/**
Invoked when a new LEDeviceInfo with info about the software and firmware revision is received from the device.
@param device      The device
@param deviceInfo  Info about software and firmware revision of the device
@param error       If an error occurred, the cause of the failure.
*/
- (void)device:(LEDevice *)device didUpdateDeviceInfo:(LEDeviceInfo *)deviceInfo error:(NSError *)error;

/**
Invoked if the device sends an updated device name.
@param device      The device
@param oldName     The previous name of the device
@param newName     The new name of the device
*/
- (void)device:(LEDevice *)device didChangeNameFrom:(NSString *)oldName to:(NSString *)newName;

/**
Invoked when the user press or release the connect-button on the device
@param device      The device
@param pressed     YES if the button is pressed, NO otherwise.
*/
- (void)device:(LEDevice *)device didChangeButtonState:(BOOL)pressed;

/**
Invoked when a device sends an updated battery level.
@param device      The device
@param newLevel    The new battery level as a number between 0 and 100.
*/
- (void)device:(LEDevice *)device didUpdateBatteryLevel:(NSNumber *)newLevel;

/**
Invoked when a device sends a low voltage notification.
@param device       The device.
@param lowVoltage   YES if the battery has 'low voltage', false otherwise.
*/
- (void)device:(LEDevice *)device didUpdateLowVoltageState:(BOOL)lowVoltage;

/** @name Monitoring changes to attached motors, sensors and other services  */

/**
Invoked when the a new motor, sensor or other service is attached to the device (Hub).

Before using the LEService you may check whether the LEService is an instance of
one of the known service types, such as LEMotor, LETiltSensor or LEMotionSensor just to mention a few.
This will allow you to use a 'safer' and more convenient interface to address the underlying IO.

@param device      The device
@param service     The attached service
*/
- (void)device:(LEDevice *)device didAddService:(LEService *)service;

/**
Invoked when a new motor, sensor or other service is detached from the device (Hub).
@param device      The device
@param service     The detached service
*/
- (void)device:(LEDevice *)device didRemoveService:(LEService *)service;

/**
Invoked when an update from the device about attached services (sensor, motors, etc) could not
be understood.
@param device      The device
@param error       The cause of the failure.
*/
- (void)device:(LEDevice *)device didFailToAddServiceWithError:(NSError *)error;

@end


/**
A device represents the physical device / Hub.
The device may have a number of services (inputs, motors, etc).

The LEDeviceManager can be used to scan for and connect to an LEDevice.

Implement the LEDeviceServiceDelegate to be notified about changes to the service attributes, for instance when a sensor has a new reading.
*/
@interface LEDevice : NSObject {
@protected
    LEMultiDelegate *_delegates;
}

/** @name Attached services (motors, sensors, etc). */

/** The currently available inputs and outputs */
@property (nonatomic, readonly) NSArray *services;

/**
An internal service is a service that is inherent to the device - something that can never be 'detached'.
Examples include the LEVoltageSensor and LECurrentSensor that
*/
@property (nonatomic, readonly) NSArray *internalServices;

/**
An external service is a service that represent and IO that can be attached to the device Hub.
Examples include the LEMotor, LETiltSensor and LEMotionSensor
*/
@property (nonatomic, readonly) NSArray *externalServices;


/** @name Device info and attributes */

/** Returns the current state of the connection. */
@property (nonatomic, readonly) LEDeviceState connectState;

/** A unique identifier for the device */
@property (nonatomic, readonly) NSString *deviceId;

/**
The most recent value of the name property read from the Hub.

Writing to this property will immediately update the property value, even though the actual write to the
hardware is asynchronously, and may potentially fail. When the write completes the [LEBluetoothHubDelegate:didChangeNameFrom:to:error]
is invoked.
*/
@property (nonatomic, copy) NSString *name;

/** The most recent button pressed state read from the Device . */
@property (nonatomic, readonly, getter=isButtonPressed) BOOL buttonPressed;

/** The System Category of the connected Device */
@property (nonatomic, readonly) LEDeviceCategory category;

/** The Fuction(s) supported by the connected Device */
@property (nonatomic, readonly) LEDeviceFunction supportedFunctions;

/** The ID of the network this Device was connected to last */
@property (nonatomic, readonly) NSUInteger lastConnectedNetworkId;

/*
The battery level of the device in percentage
If no battery level has been received from the Device, the value is null
*/
@property (nonatomic, readonly) NSNumber * batteryLevel;

/** True if the a low voltage alert has been received from the Device, indicating that batteries should be changed/charged */
@property (nonatomic, readonly) BOOL lowVoltage;

/** Info about the device hardware, firmware, and software revision */
@property (nonatomic, readonly) LEDeviceInfo *deviceInfo;

#pragma mark - Add and remove delegates
/** @name Add and remove delegates */

/**
* If a delegate is registered it receives callbacks on changes to offered services,
* as well as properties of the device like name and color.
* @param delegate The delegate to add
*/
- (void)addDelegate:(id <LEDeviceDelegate>)delegate;

/**
* Remove delegate from this device
* @param delegate The delegate to remove
*/
- (void)removeDelegate:(id <LEDeviceDelegate>)delegate;


#pragma mark - Check for equality
/** @name Check for equality */

/**
Returns YES if this device is equal to otherDevice
@param otherDevice     The device to be compared to the receiver.
*/
- (BOOL)isEqualToDevice:(LEDevice *)otherDevice;

@end