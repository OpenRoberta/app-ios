//
// Created by Søren Toft Odgaard on 8/15/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LEDevice.h"

@class LEBluetoothDeviceManager;
@class LEBluetoothDevice;

@protocol LEBluetoothDeviceManagerDelegate <NSObject>

@optional

- (void)deviceManager:(LEBluetoothDeviceManager *)manager deviceDidAppear:(LEBluetoothDevice *)device;

- (void)deviceManager:(LEBluetoothDeviceManager *)manager deviceDidDisappear:(LEBluetoothDevice *)device;

- (void)deviceManager:(LEBluetoothDeviceManager *)manager willStartConnectingToDevice:(LEBluetoothDevice *)device;

- (void)deviceManager:(LEBluetoothDeviceManager *)manager didStartInterrogatingDevice:(LEBluetoothDevice *)device;

- (void)deviceManager:(LEBluetoothDeviceManager *)manager didFinishInterrogatingDevice:(LEBluetoothDevice *)btDevice;

- (void)deviceManager:(LEBluetoothDeviceManager *)manager didDisconnectFromDevice:(LEBluetoothDevice *)device willAttemptAutoReconnect:(BOOL)autoReconnect error:(NSError *)error;

- (void)deviceManager:(LEBluetoothDeviceManager *)manager didFailToConnectToDevice:(LEBluetoothDevice *)device willAttemptAutoReconnect:(BOOL)autoReconnect error:(NSError *)error;

@end

@interface LEBluetoothDeviceManager : NSObject

- (id)initWithCentralManager:(CBCentralManager *)centralManager;

- (void)scan;

- (void)stopScanning;


@property (nonatomic, weak) id <LEBluetoothDeviceManagerDelegate> delegate;

- (void)connectToDevice:(LEBluetoothDevice *)device;

@property (nonatomic, readwrite) BOOL automaticReconnectOnConnectionLostEnabled;

@property (nonatomic, readwrite) NSTimeInterval connectRequestTimeoutInterval;

- (void)cancelDeviceConnection:(LEBluetoothDevice *)device;

- (NSArray *)devicesInState:(LEDeviceState)connectState;

@property (nonatomic, readonly) NSArray *allDevices;

@property (nonatomic, readwrite) NSTimeInterval updateAdvertisingDevicesInterval;

@end