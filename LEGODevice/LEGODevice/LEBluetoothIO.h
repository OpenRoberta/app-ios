//
// Created by Søren Toft Odgaard on 9/6/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//
#include <CoreBluetooth/CoreBluetooth.h>

#import "LEIO.h"

@class LECharacteristicDefinition;
@class LEInputFormat;
@class LEBluetoothDevice;


@interface LEBluetoothIO : LEIO

- (id)initWithService:(CBService *)service;

+ (LEBluetoothIO *)bluetoothIOWithService:(CBService *)service;

@property (nonatomic, readonly) CBService *service;

- (void)handleUpdatedInputServiceCharacteristic:(CBCharacteristic *)characteristic;

- (void)handleWriteResponseFromIOServiceWithCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error;

@end