//
// Created by Søren Toft Odgaard on 9/6/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "LEDevice.h"
#import "LEIO.h"

@class CBPeripheral;
@class LEBluetoothDevice;
@class LEBluetoothIO;
@class LEMotor;
@class LEIO;
@class LEDeviceInfoServiceDefinition;

@interface LEBluetoothDevice : LEDevice

@property (nonatomic, readonly) NSNumber *RSSI;
@property (nonatomic, readonly) CBPeripheral *peripheral;
@property (nonatomic, readonly) NSDictionary *advertisementData;

@end