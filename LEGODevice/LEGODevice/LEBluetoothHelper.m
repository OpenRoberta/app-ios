//
// Created by Søren Toft Odgaard on 8/21/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "LEBluetoothHelper.h"
#import "LELogger+Project.h"

#define LE_UUID_BASE @"1212-EFDE-1523-785FEABCD123"


@implementation LEBluetoothHelper

+ (NSString *)UUIDWithPrefix:(NSString *)prefix
{
    NSString *padding = [@"" stringByPaddingToLength:(8 - prefix.length) withString:@"0" startingAtIndex:0];
    return [NSString stringWithFormat:@"%@%@-%@", padding, prefix, LE_UUID_BASE];
}

+ (CBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicUUID inService:(CBService *)service
{
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:characteristicUUID]) {
            return characteristic;
        }
    }
    return nil;
}

+ (CBService *)serviceWithUUID:(CBUUID *)serviceUUID inPeripheral:(CBPeripheral *)peripheral
{
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:serviceUUID]) {
            return service;
        }
    }
    return nil;
}

+ (NSArray *)arrayOfStringsFromCharacteristicProperties:(CBCharacteristicProperties)properties
{
    static NSMutableDictionary *propStrings;
    if (!propStrings) {
        propStrings = [NSMutableDictionary dictionaryWithCapacity:10];
    }

    //By using a switch the compiler will warn us if we leave out a possible value.
    //Make sure the first 'case' is hit and don't 'break' out of the switch to make sure all followings 'cases' are also hit.
    CBCharacteristicProperties firstProperty = CBCharacteristicPropertyBroadcast;
    switch (firstProperty) {
        case CBCharacteristicPropertyBroadcast:
            propStrings[@(CBCharacteristicPropertyBroadcast)] = @"CBCharacteristicPropertyBroadcast";
        case CBCharacteristicPropertyRead:
            propStrings[@(CBCharacteristicPropertyRead)] = @"CBCharacteristicPropertyRead";
        case CBCharacteristicPropertyWriteWithoutResponse:
            propStrings[@(CBCharacteristicPropertyWriteWithoutResponse)] = @"CBCharacteristicPropertyWriteWithoutResponse";
        case CBCharacteristicPropertyWrite:
            propStrings[@(CBCharacteristicPropertyWrite)] = @"CBCharacteristicPropertyWrite";
        case CBCharacteristicPropertyNotify:
            propStrings[@(CBCharacteristicPropertyNotify)] = @"CBCharacteristicPropertyNotify";
        case CBCharacteristicPropertyIndicate:
            propStrings[@(CBCharacteristicPropertyIndicate)] = @"CBCharacteristicPropertyIndicate";
        case CBCharacteristicPropertyAuthenticatedSignedWrites:
            propStrings[@(CBCharacteristicPropertyAuthenticatedSignedWrites)] = @"CBCharacteristicPropertyAuthenticatedSignedWrites";
        case CBCharacteristicPropertyExtendedProperties:
            propStrings[@(CBCharacteristicPropertyExtendedProperties)] = @"CBCharacteristicPropertyExtendedProperties";
        case CBCharacteristicPropertyNotifyEncryptionRequired:
            propStrings[@(CBCharacteristicPropertyNotifyEncryptionRequired)] = @"CBCharacteristicPropertyNotifyEncryptionRequired";
        case CBCharacteristicPropertyIndicateEncryptionRequired:
            propStrings[@(CBCharacteristicPropertyIndicateEncryptionRequired)] = @"CBCharacteristicPropertyIndicateEncryptionRequired";
    }

    //By using a switch the compiler will warn us if we leave out a possible value.
    NSMutableArray *result = [NSMutableArray new];
    switch (firstProperty) {
        case CBCharacteristicPropertyBroadcast:
            if (properties & CBCharacteristicPropertyBroadcast) [result addObject:propStrings[@(CBCharacteristicPropertyBroadcast)]];
        case CBCharacteristicPropertyRead:
            if (properties & CBCharacteristicPropertyRead) [result addObject:propStrings[@(CBCharacteristicPropertyRead)]];
        case CBCharacteristicPropertyWriteWithoutResponse:
            if (properties & CBCharacteristicPropertyWriteWithoutResponse) [result addObject:propStrings[@(CBCharacteristicPropertyWriteWithoutResponse)]];
        case CBCharacteristicPropertyWrite:
            if (properties & CBCharacteristicPropertyWrite) [result addObject:propStrings[@(CBCharacteristicPropertyWrite)]];
        case CBCharacteristicPropertyNotify:
            if (properties & CBCharacteristicPropertyNotify) [result addObject:propStrings[@(CBCharacteristicPropertyNotify)]];
        case CBCharacteristicPropertyIndicate:
            if (properties & CBCharacteristicPropertyIndicate) [result addObject:propStrings[@(CBCharacteristicPropertyIndicate)]];
        case CBCharacteristicPropertyAuthenticatedSignedWrites:
            if (properties & CBCharacteristicPropertyAuthenticatedSignedWrites) [result addObject:propStrings[@(CBCharacteristicPropertyAuthenticatedSignedWrites)]];
        case CBCharacteristicPropertyExtendedProperties:
            if (properties & CBCharacteristicPropertyExtendedProperties) [result addObject:propStrings[@(CBCharacteristicPropertyExtendedProperties)]];
        case CBCharacteristicPropertyNotifyEncryptionRequired:
            if (properties & CBCharacteristicPropertyNotifyEncryptionRequired) [result addObject:propStrings[@(CBCharacteristicPropertyNotifyEncryptionRequired)]];
        case CBCharacteristicPropertyIndicateEncryptionRequired:
            if (properties & CBCharacteristicPropertyIndicateEncryptionRequired) [result addObject:propStrings[@(CBCharacteristicPropertyIndicateEncryptionRequired)]];
    }

    return result;
}


+ (NSArray *)characteristicUUIDsFromService:(CBService *)service
{
    NSMutableArray *result = [NSMutableArray new];
    for (CBCharacteristic *characteristic in service.characteristics) {
        [result addObject:characteristic.UUID];
    }
    return result;
}



@end