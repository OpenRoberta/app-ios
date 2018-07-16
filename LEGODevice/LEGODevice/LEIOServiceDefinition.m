//
// Created by Søren Toft Odgaard on 14/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEIOServiceDefinition.h"
#import "LEBluetoothHelper.h"
#import "LELogger+Project.h"

#define LE_INPUT_SERVICE_UUID @"4F0E"

#define LE_CHARACTERISTIC_INPUT_VALUE_UUID @"1560"
#define LE_CHARACTERISTIC_INPUT_FORMAT_UUID @"1561"
#define LE_CHARACTERISTIC_INPUT_COMMAND_UUID @"1563"
#define LE_CHARACTERISTIC_OUTPUT_COMMAND_UUID @"1565"

@implementation LEIOServiceDefinition

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
        _UUID = [CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_INPUT_SERVICE_UUID]];
        _name = @"IOService";

        _inputValue = [LECharacteristicDefinition
                characteristicWithName:@"InputValues"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_CHARACTERISTIC_INPUT_VALUE_UUID]]
                mandatory:YES
                mandatoryProperties:CBCharacteristicPropertyNotify
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _inputFormat = [LECharacteristicDefinition
                characteristicWithName:@"InputFormats"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_CHARACTERISTIC_INPUT_FORMAT_UUID]]
                mandatory:YES
                mandatoryProperties:CBCharacteristicPropertyNotify
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _inputCommand = [LECharacteristicDefinition
                characteristicWithName:@"InputCommand"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_CHARACTERISTIC_INPUT_COMMAND_UUID]]
                mandatory:YES
                mandatoryProperties:(CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyWrite)
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsWriteable
        ];

        _outputCommand = [LECharacteristicDefinition
                characteristicWithName:@"OutputCommand"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:[LEBluetoothHelper UUIDWithPrefix:LE_CHARACTERISTIC_OUTPUT_COMMAND_UUID]]
                mandatory:YES
                mandatoryProperties:(CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicPropertyWrite)
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsWriteable
        ];


        _characteristicDefinitions = @[
                [self inputValue],
                [self inputFormat],
                [self inputCommand],
                [self outputCommand],
        ];

    }

    return self;
}


@end