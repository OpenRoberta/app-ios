//
// Created by Søren Toft Odgaard on 29/10/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CoreBluetoothMockFactory : NSObject

#pragma mark - Services and Peripheral
+ (CBPeripheral *)peripheralWithServices;

+ (CBService *)inputServiceWithPeripheral:(CBPeripheral *)peripheral;

+ (CBService *)inputService;

+ (CBService *)deviceServiceWithPeripheral:(CBPeripheral *)peripheral;


#pragma mark -  IO Service Characteristics
+ (CBCharacteristic *)inputValueCharacteristicWithData:(NSData *)valueData;

+ (CBCharacteristic *)inputFormatCharacteristicWithData:(NSData *)valueData;

+ (CBCharacteristic *)inputCommandCharacteristicWithData:(NSData *)valueData;


#pragma mark - Device Service Characteristics
+ (CBCharacteristic *)deviceNameCharacteristicWithData:(NSData *)data peripheral:(CBPeripheral *)peripheral;

+ (CBCharacteristic *)deviceTypesAttachedCharacteristicWithData:(NSData *)data peripheral:(CBPeripheral *)peripheral;

+ (CBCharacteristic *)deviceButtonCharacteristicWithData:(NSData *)data peripheral:(CBPeripheral *)peripheral;

+ (CBCharacteristic *)deviceLowVoltageAlertCharacteristicWithData:(NSData *)data peripheral:(CBPeripheral *)peripheral;


#pragma mark - Helpers for setting mock invocation expectations

+ (void)expectDataWritten:(NSData *)data type:(CBCharacteristicWriteType)type service:(CBService *)service characteristicUUID:(CBUUID *)characteristicUUID;

+ (void)verifyMockPeripheralInService:(CBService *)service;


@end