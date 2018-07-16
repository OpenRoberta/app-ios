//
// Created by Søren Toft Odgaard on 14/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@class LEBluetoothServiceDefinition;


@interface LECharacteristicDefinition : NSObject

#pragma mark - Creating and initializing Characteristic Definitions
- (instancetype)initWithName:(NSString *)name
          serviceDescription:(LEBluetoothServiceDefinition *)serviceDescription
                        UUID:(CBUUID *)UUID
                   mandatory:(BOOL)mandatory
         mandatoryProperties:(CBCharacteristicProperties)mandatoryProperties
       recommendedProperties:(CBCharacteristicProperties)recommendedProperties
                 permissions:(CBAttributePermissions)permissions;

+ (instancetype)characteristicWithName:(NSString *)name
                     serviceDefinition:(LEBluetoothServiceDefinition *)serviceName
                                  UUID:(CBUUID *)UUID
                             mandatory:(BOOL)mandatory
                   mandatoryProperties:(CBCharacteristicProperties)mandatoryProperties
                 recommendedProperties:(CBCharacteristicProperties)recommendedProperties
                           permissions:(CBAttributePermissions)permissions;


#pragma mark - Definition Properties
@property (readonly, weak) LEBluetoothServiceDefinition *serviceDefinition;

@property (readonly) NSString *name;

@property (readonly) CBUUID *UUID;

@property (readonly, getter=isMandatory) BOOL mandatory;

@property (readonly) CBCharacteristicProperties mandatoryProperties;

@property (readonly) CBCharacteristicProperties recommendedProperties;

@property (readonly) CBAttributePermissions permissions;

#pragma mark - Validation

- (NSError *)validateDefinitionIsSatisfiedByCharacteristic:(CBCharacteristic *)characteristic;

- (BOOL)matchesCharacteristic:(CBCharacteristic *)characteristic;


#pragma mark - Description
- (NSString *)description;

- (NSString *)shortDescription;


#pragma mark - Equals and Hash

- (BOOL)isEqual:(id)other;

- (BOOL)isEqualToCharacteristic:(LECharacteristicDefinition *)characteristic;

- (NSUInteger)hash;


@end