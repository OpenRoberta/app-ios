//
//  LEDeviceManager.h
//  LEGODevice
//
//  Created by Jon Nørrelykke on 24/10/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEDevice.h"

@class LEDeviceManager;
@class LEDevice;

/**
* The default connect request timeout.
*/
static const NSTimeInterval LEDefaultConnectRequestTimeout = 10;

/**
 Implement this protocol to be notified when a new device starts or stops advertising, and when a connection to a
 device is established or closed.
 */
@protocol LEDeviceManagerDelegate <NSObject>

@optional

/** @name Monitoring Advertising Devices */

/**
 Invoked when a device advertising a LEGO Device service UUID is discovered.
 @param manager    The LEDeviceManager
 @param device     The discovered device
 */
- (void)deviceManager:(LEDeviceManager *)manager deviceDidAppear:(LEDevice *)device;

/**
 Invoked when a device stops advertising a LEGO Device service.
 The LEDeviceManager will check at small refresh-intervals if an advertising
 packet was received during the refresh-interval. If not, this method is invoked.
 @param manager    The LEDeviceManager
 @param device     The device that stopped advertising
 */
- (void)deviceManager:(LEDeviceManager *)manager deviceDidDisappear:(LEDevice *)device;


/** @name Monitoring Device Connection State */

/**
 Invoked when starting a device connect attempt. Normally, this will happen right after calling
 [LEDeviceManager connectToDevice:]. However, it may also happen in relation to an automatic reconnect
 attempt.
 @param manager    The LEDeviceManager
 @param device     The device that stopped advertising
 @see              [LEDeviceManager automaticReconnectOnConnectionLostEnabled]
 @see              [LEDeviceManager connectToDevice:]
*/
- (void)deviceManager:(LEDeviceManager *)manager willStartConnectingToDevice:(LEDevice *)device;


/**
 Invoked when a connection to a device is established, and the interrogation of the
 device for required services begins. A connection is established at this point
 but the device is not yet ready to be used.

 @param manager    The LEDeviceManager
 @param device     The connected device
 */
- (void)deviceManager:(LEDeviceManager *)manager didStartInterrogatingDevice:(LEDevice *)device;

/**
 Invoked when a connection to a device is established and all required services has been discovered.
 At this point the device is ready for use.

 @param manager    The LEDeviceManager
 @param device     The connected device
*/
- (void)deviceManager:(LEDeviceManager *)manager didFinishInterrogatingDevice:(LEDevice *)device;

/**
 Invoked when a device is disconnected.

 @param manager        The LEDeviceManager
 @param device         The disconnected device
 @param autoReconnect  YES if an automatic reconnect will be attempted, see [LEDeviceManager automaticReconnectOnConnectionLostEnabled].
 @param error          If an error occurred, the cause of the failure.
 */
- (void)deviceManager:(LEDeviceManager *)manager didDisconnectFromDevice:(LEDevice *)device willAttemptAutoReconnect:(BOOL)autoReconnect error:(NSError *)error;

/**
 Invoked when a device fails to connect, of if a connection request times out.

 @param manager        The LEDeviceManager
 @param device         The device that failed to connect
 @param autoReconnect  YES if an automatic reconnect will be attempted, see [LEDeviceManager automaticReconnectOnConnectionLostEnabled].
 @param error          The cause of the failure.
 */
- (void)deviceManager:(LEDeviceManager *)manager didFailToConnectToDevice:(LEDevice *)device willAttemptAutoReconnect:(BOOL)autoReconnect error:(NSError *)error;


@end

/**
 This class is the main entry point for connecting and communicating with a LEGO Device.
 You must implement the LEDeviceManagerDelegate protocol and set the delegate property
 before scanning for and connecting to devices.
 */
@interface LEDeviceManager : NSObject

/** @name Getting an instance of the Device Manager */

/** @return The shared LEDeviceManager */
+ (LEDeviceManager *)sharedDeviceManager;

/** @name Scan for Devices  */

/**
 Start scanning for LEGO BLE devices
 */
- (void)scan;

/**
 Stop scanning for LEGO BLE devices and removes all discovered but un-connected devices
 from the list of allDevices
 */
- (void)stopScanning;

/** @name Connect and Disconnect */

/**
 Connect to a LEGO LEDevice.
 If a connection is not established within the connectRequestTimeoutInterval the connection attempt is cancelled
 and the [LEDeviceManagerDelegate deviceManager:didFailToConnectToDevice:error] is invoked.
 @param device  The device to establish a connection to
 */
- (void)connectToDevice:(LEDevice *)device;

/**
 If a connect request is not successful within this time interval the connection attempt is cancelled
 and the [LEDeviceManagerDelegate deviceManager:didFailToConnectToDevice:error] is invoked.
 The default value is 10 seconds.
*/
@property (nonatomic, readwrite) NSTimeInterval connectRequestTimeoutInterval;

/**
 If enabled, the LEGDeviceManager will attempt to reconnect in case of a connection loss, but only if the connection was not closed by the user,
 the default value is NO.

 If this property is set to YES an automatic attempt to connect is made in the following cases:

   * If a connection requests fails with an 'unexpected error' (e.g. not due to a time-out). If the second connection attempt also fails,
    no further attempts are made to connect automatically.
   * If a connection in lost in state LEDeviceStateInterrogating with an 'unexpected error' (e.g. not closed by user).
     If the second connection attempt also fails, no further attempts are made to connect automatically.
   * If a connection is lost after successful connection (i.e. in state LEDeviceStateInterrogationFinished)

 If the connect-request does not succeed within the connectRequestTimeout no attempt is made to automatically reconnect.
*/
@property (nonatomic, readwrite) BOOL automaticReconnectOnConnectionLostEnabled;


/**
 Disconnect from a LEGO Bluetooth LE Device.
 @param device  The device to disconnect from
*/
- (void)cancelDeviceConnection:(LEDevice *)device;


/*
 Returns a list of devices in the specified device state. Use this, for example, to retrieve a list
 of all advertising but non-connected devices, i.e. LEDeviceDisconnected.
 @param connectState    The state of the devices.
 */
- (NSArray *)devicesInState:(LEDeviceState)connectState;

/**
 Returns a list with all known devices regardless of their current connect state.

 For BLE devices, the list is ordered according to relative distance, based of the RSSI values received for each Device.
 The Device closest will be first in the list. Note, the RSSI value is only updated while in advertising mode.

*/
@property (nonatomic, readonly) NSArray *allDevices;


/** @name Add and Remove delegates */

/**
 Add a delegate to receive device discovery and connection events
 @param delegate    The delegate to add
*/
- (void)addDelegate:(id <LEDeviceManagerDelegate>)delegate;

/**
 Remove a delegate
 @param delegate    The delegate to remove
*/
- (void)removeDelegate:(id <LEDeviceManagerDelegate>)delegate;


@end