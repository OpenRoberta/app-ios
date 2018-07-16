//
// Created by Søren Toft Odgaard on 8/21/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface LEBluetoothHelper : NSObject

+ (NSString *)UUIDWithPrefix:(NSString *)prefix;

+ (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID inService:(CBService *)service;

+ (CBService *)serviceWithUUID:(CBUUID *)serviceUUID inPeripheral:(CBPeripheral *)peripheral;

+ (NSArray *)characteristicUUIDsFromService:(CBService *)service;

+ (NSArray *)arrayOfStringsFromCharacteristicProperties:(CBCharacteristicProperties)properties;

@end