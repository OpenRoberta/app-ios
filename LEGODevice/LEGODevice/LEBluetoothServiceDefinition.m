//
// Created by Søren Toft Odgaard on 14/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEBluetoothServiceDefinition.h"
#import "LELogger+Project.h"
#import "LEBluetoothHelper.h"
#import "LEIOServiceDefinition.h"
#import "LEDeviceServiceDefinition.h"
#import "LEErrorCodes.h"
#import "LEBatteryServiceDefinition.h"
#import "LEDeviceInfoServiceDefinition.h"


@implementation LEBluetoothServiceDefinition {
    NSMutableArray *_characteristicUUIDs;
}

#pragma mark - Getting an instance of a Bluetooth Service Definition
+ (LEIOServiceDefinition *)ioServiceDefinition
{
    return [LEIOServiceDefinition sharedInstance];
}

+ (LEDeviceServiceDefinition *)deviceServiceDefinition
{
    return [LEDeviceServiceDefinition sharedInstance];
}

+ (LEDeviceInfoServiceDefinition *)deviceInfoServiceDefinition
{
    return [LEDeviceInfoServiceDefinition sharedInstance];
}

+ (LEBatteryServiceDefinition *)batteryServiceDefinition
{
    return [LEBatteryServiceDefinition sharedInstance];
}


+ (LEBluetoothServiceDefinition *)serviceDefinitionWithUUID:(CBUUID *)serviceUUID
{
    if ([[self ioServiceDefinition].serviceUUID isEqual:serviceUUID]) {
        return [self ioServiceDefinition];
    } else if ([[self deviceServiceDefinition].serviceUUID isEqual:serviceUUID]) {
        return [self deviceServiceDefinition];
    } else if ([[self deviceInfoServiceDefinition].serviceUUID isEqual:serviceUUID]) {
        return [self deviceInfoServiceDefinition];
    } else if ([[self batteryServiceDefinition].serviceUUID isEqual:serviceUUID]) {
        return [self batteryServiceDefinition];
    }
    return nil;
}


#pragma mark - Validation

- (NSError *)validateDefinitionIsSatisfiedByService:(CBService *)service
{
    if (![service.UUID isEqual:self.serviceUUID]) {
        LEErrorLog(@"Service UUID does not match Service definition", service.UUID.data, self.shortDescription);
        NSString *errorMessage = [NSString stringWithFormat:@"Interal error while validating service with UUID %@", service.UUID.data];
        return [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeInternalError userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
    }

    for (LECharacteristicDefinition *definition in self.characteristicDefinitions) {
        CBCharacteristic *characteristic = [self characteristicForDefinition:definition inService:service];

        if (!characteristic) {
            if (definition.isMandatory) {
                NSString *errorMessage = [NSString stringWithFormat:@"Could not find mandatory characteritic %@", definition.shortDescription];
                LEDebugLog(@"Service %@ has characteristics: %@", definition.shortDescription, [LEBluetoothHelper characteristicUUIDsFromService:service]);
                return [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeBluetoothMissingCharacteristics userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
            } else {
                LEDebugLog(@"Did not find optionel characteritic %@ on service %@", definition.shortDescription, self.shortDescription);
            }
        } else {
            NSError *error = [definition validateDefinitionIsSatisfiedByCharacteristic:characteristic];
            if (error) {
                return error;
            }
        }
    }

    return nil;
}

- (BOOL)matchesService:(CBService *)service
{
    return [self.serviceUUID isEqual:service.UUID];
}


#pragma mark - Service Definition
- (CBCharacteristic *)characteristicForDefinition:(LECharacteristicDefinition *)definition inService:(CBService *)service
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:definition.UUID]) {
            return characteristic;
        }
    }
    return nil;
}

- (NSArray *)characteristicUUIDs
{
    if (!_characteristicUUIDs) {
        _characteristicUUIDs = [NSMutableArray arrayWithCapacity:self.characteristicDefinitions.count];
        for (LECharacteristicDefinition *definition in self.characteristicDefinitions) {
            [_characteristicUUIDs addObject:definition.UUID];
        }
    }
    return _characteristicUUIDs;
}

- (LECharacteristicDefinition *)characteristicDefinitionWithUUID:(CBUUID *)UUID
{
    for (LECharacteristicDefinition *definition in self.characteristicDefinitions) {
        if ([definition.UUID isEqual:UUID]) {
            return definition;
        }
    }
    LEDebugLog(@"Did not find characteristic with UUID %@ in service %@", UUID.data, self.serviceName);
    return nil;
}

#pragma mark - Description
- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"< %@", self.serviceName];
    [description appendFormat:@"(%@)", self.serviceUUID];
    [description appendFormat:@", self.characteristicDefinitions=%@", self.characteristicDefinitions];
    [description appendString:@">"];
    return description;
}

- (NSString *)debugDescription
{
    return [self description];
}

- (NSString *)shortDescription
{
    return [NSString stringWithFormat:@"%@(%@)", self.serviceName, self.serviceUUID.data];
}


#pragma mark - Equals and Hash
- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToDefinition:other];
}

- (BOOL)isEqualToDefinition:(LEBluetoothServiceDefinition *)definition
{
    if (self == definition)
        return YES;
    if (definition == nil)
        return NO;
    if (self.serviceName != definition.serviceName && ![self.serviceName isEqualToString:definition.serviceName])
        return NO;
    if (self.serviceUUID != definition.serviceUUID && ![self.serviceUUID isEqual:definition.serviceUUID])
        return NO;
    if (self.characteristicDefinitions != definition.characteristicDefinitions && ![self.characteristicDefinitions isEqualToArray:definition.characteristicDefinitions])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = [self.serviceName hash];
    hash = hash * 31u + [self.serviceUUID hash];
    hash = hash * 31u + [self.characteristicDefinitions hash];
    return hash;
}


@end