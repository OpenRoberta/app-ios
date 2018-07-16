//
// Created by Søren Toft Odgaard on 14/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LECharacteristicDefinition.h"
#import "LEBluetoothHelper.h"
#import "LELogger+Project.h"
#import "LEErrorCodes.h"
#import "LEBluetoothServiceDefinition.h"

@implementation LECharacteristicDefinition {

}

#pragma mark - Creating and initializing Characteristic Definitions

- (instancetype)initWithName:(NSString *)name
          serviceDescription:(LEBluetoothServiceDefinition *)serviceDescription
                        UUID:(CBUUID *)UUID
                   mandatory:(BOOL)mandatory
         mandatoryProperties:(CBCharacteristicProperties)mandatoryProperties
       recommendedProperties:(CBCharacteristicProperties)recommendedProperties
                 permissions:(CBAttributePermissions)permissions
{
    self = [super init];
    if (self) {
        _name = name;
        _serviceDefinition = serviceDescription;
        _UUID = UUID;
        _mandatory = mandatory;
        _mandatoryProperties = mandatoryProperties;
        _recommendedProperties = recommendedProperties;
        _permissions = permissions;
    }
    return self;
}

+ (instancetype)characteristicWithName:(NSString *)name
                     serviceDefinition:(LEBluetoothServiceDefinition *)serviceName
                                  UUID:(CBUUID *)UUID
                             mandatory:(BOOL)mandatory
                   mandatoryProperties:(CBCharacteristicProperties)mandatoryProperties
                 recommendedProperties:(CBCharacteristicProperties)recommendedProperties
                           permissions:(CBAttributePermissions)permissions
{
    return [[self alloc] initWithName:name serviceDescription:serviceName UUID:UUID mandatory:mandatory mandatoryProperties:mandatoryProperties recommendedProperties:recommendedProperties permissions:permissions];
}

#pragma mark - Validation

- (NSError *)validateDefinitionIsSatisfiedByCharacteristic:(CBCharacteristic *)characteristic
{
    NSError *error = nil;
    if (self.mandatoryProperties != 0 && !(characteristic.properties & self.mandatoryProperties)) {
        NSString *errorMessage = [NSString stringWithFormat:@"Characteristic %@ with properties %@ does not include mandatory properties %@",
                        self.shortDescription, [self stringsFromProperties:characteristic.properties], [self stringsFromProperties:self.mandatoryProperties]];
        error = [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeBluetoothInvalidCharacteristicProperties userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
    }

    if (self.recommendedProperties != 0 && !(characteristic.properties & self.recommendedProperties)) {
        LEWarnLog(@"Characteristic %@ with properties %@ does not include recommended properties %@", self.shortDescription,
        [self stringsFromProperties:characteristic.properties],
        [self stringsFromProperties:self.recommendedProperties]);
    }

    return error;
}

- (BOOL)matchesCharacteristic:(CBCharacteristic *)characteristic
{
    return [self.UUID isEqual:characteristic.UUID];
}

#pragma mark - Description
- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"name=%@", self.name];
    [description appendFormat:@", serviceName=%@", self.serviceDefinition.serviceName];
    [description appendFormat:@", UUID=%@", self.UUID.data];
    [description appendFormat:@", isMandatory=%d", self.mandatory];
    [description appendFormat:@", mandatoryProperties=%@", [LEBluetoothHelper arrayOfStringsFromCharacteristicProperties:self.mandatoryProperties]];
    [description appendFormat:@", recommendedProperties=%@", [LEBluetoothHelper arrayOfStringsFromCharacteristicProperties:self.recommendedProperties]];
    [description appendString:@">"];
    return description;
}

- (NSString *)shortDescription
{
    return [NSString stringWithFormat:@"%@.%@(%@)", self.serviceDefinition.serviceName, self.name, self.UUID.data];
}

- (NSArray *)stringsFromProperties:(CBCharacteristicProperties)properties
{
    return [LEBluetoothHelper arrayOfStringsFromCharacteristicProperties:properties];
}


#pragma mark - Equals and Hash
- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToCharacteristic:other];
}

- (BOOL)isEqualToCharacteristic:(LECharacteristicDefinition *)characteristic
{
    if (self == characteristic)
        return YES;
    if (characteristic == nil)
        return NO;
    if (self.name != characteristic.name && ![self.name isEqualToString:characteristic.name])
        return NO;
    if (self.UUID != characteristic.UUID && ![self.UUID isEqual:characteristic.UUID])
        return NO;
    if (self.mandatory != characteristic.mandatory)
        return NO;
    if (self.mandatoryProperties != characteristic.mandatoryProperties)
        return NO;
    if (self.recommendedProperties != characteristic.recommendedProperties)
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = [self.name hash];
    hash = hash * 31u + [self.UUID hash];
    hash = hash * 31u + self.mandatory;
    hash = hash * 31u + (NSUInteger) self.mandatoryProperties;
    hash = hash * 31u + (NSUInteger) self.recommendedProperties;
    return hash;
}


@end

