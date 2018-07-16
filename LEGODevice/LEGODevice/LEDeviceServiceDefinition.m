//
// Created by Søren Toft Odgaard on 15/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEDeviceServiceDefinition.h"
#import "LEBluetoothHelper.h"

#define LE_HUB_SERVICE_16_BIT_UUID @"1523"
#define LE_HUB_CHARACTERISTIC_NAME_UUID @"1524"
#define LE_HUB_CHARACTERISTIC_BUTTON_STATE @"1526"
#define LE_HUB_CHARACTERISTIC_ATTACHED_IO @"1527"
#define LE_HUB_CHARACTERISTIC_LOW_VOLTAGE_ALERT @"1528"

@implementation LEDeviceServiceDefinition

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
        _UUID = [CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_HUB_SERVICE_16_BIT_UUID]];
        _name = @"DeviceService";

        _deviceName = [LECharacteristicDefinition
                characteristicWithName:@"DeviceName"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_HUB_CHARACTERISTIC_NAME_UUID]]
                mandatory:YES
                mandatoryProperties:(CBCharacteristicPropertyWrite | CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyRead)
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:(CBAttributePermissionsWriteable | CBAttributePermissionsReadable)
        ];

        _attachedIO = [LECharacteristicDefinition
                characteristicWithName:@"AttachedIO"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_HUB_CHARACTERISTIC_ATTACHED_IO]]
                mandatory:YES
                mandatoryProperties:(CBCharacteristicPropertyNotify)
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _deviceButton = [LECharacteristicDefinition
                characteristicWithName:@"DeviceButton"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_HUB_CHARACTERISTIC_BUTTON_STATE]]
                mandatory:YES
                mandatoryProperties:(CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify)
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _lowVoltageAlert = [LECharacteristicDefinition
                characteristicWithName:@"LowVoltageAlert"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_HUB_CHARACTERISTIC_LOW_VOLTAGE_ALERT]]
                mandatory:NO
                mandatoryProperties:(CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify)
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _characteristicDefinitions = @[
                [self deviceName],
                [self attachedIO],
                [self deviceButton],
                [self lowVoltageAlert],
        ];
    }
    return self;
}


- (CBUUID *)shortServiceUUID
{
    return [CBUUID UUIDWithString:LE_HUB_SERVICE_16_BIT_UUID];
}


@end