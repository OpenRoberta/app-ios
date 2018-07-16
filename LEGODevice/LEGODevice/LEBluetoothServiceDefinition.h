//
// Created by Søren Toft Odgaard on 14/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LECharacteristicDefinition.h"

@class CBUUID;
@class LEIOServiceDefinition;
@class LEDeviceServiceDefinition;
@class LEBatteryServiceDefinition;
@class LEDeviceInfoServiceDefinition;


@interface LEBluetoothServiceDefinition : NSObject

#pragma mark - Getting an instance of a Bluetooth Service Definition
+ (LEIOServiceDefinition *)ioServiceDefinition;

+ (LEDeviceServiceDefinition *)deviceServiceDefinition;

+ (LEDeviceInfoServiceDefinition *)deviceInfoServiceDefinition;

+ (LEBatteryServiceDefinition *)batteryServiceDefinition;

+ (LEBluetoothServiceDefinition *)serviceDefinitionWithUUID:(CBUUID *)serviceUUID;

#pragma mark - Service Definition
@property (readonly) NSString *serviceName;

@property (readonly) CBUUID *serviceUUID;

@property (readonly) NSArray *characteristicDefinitions;

@property (readonly) NSArray *characteristicUUIDs;

- (LECharacteristicDefinition *)characteristicDefinitionWithUUID:(CBUUID *)UUID;

#pragma mark - Validation
- (NSError *)validateDefinitionIsSatisfiedByService:(CBService *)service;

- (BOOL)matchesService:(CBService *)service;

#pragma mark - Description
- (NSString *)description;

- (NSString *)shortDescription;

#pragma mark - Equals and hash
- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToDefinition:(LEBluetoothServiceDefinition *)definition;

- (NSUInteger)hash;


@end