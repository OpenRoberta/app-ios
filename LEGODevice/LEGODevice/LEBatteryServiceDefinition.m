//
// Created by Søren Toft Odgaard on 27/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEBatteryServiceDefinition.h"

#define LE_BATTERY_SERVICE_UUID @"0x180F"

#define LE_BATTERY_LEVEL_CHARACTERISTIC_UUID @"0x2A19"

@implementation LEBatteryServiceDefinition

@synthesize serviceUUID = _UUID;
@synthesize characteristicDefinitions = _characteristicDefinitions;
@synthesize serviceName = _name;


+ (instancetype)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}


- (id)init
{
    self = [super init];
    if (self) {
        _UUID = [CBUUID UUIDWithString:LE_BATTERY_SERVICE_UUID];
        _name = @"BatteryService";

        _batteryLevel = [LECharacteristicDefinition
                characteristicWithName:@"InputValues"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:LE_BATTERY_LEVEL_CHARACTERISTIC_UUID]
                mandatory:YES
                mandatoryProperties:CBCharacteristicPropertyNotify | CBCharacteristicPropertyRead
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _characteristicDefinitions = @[ self.batteryLevel ];

    }

    return self;
}


@end