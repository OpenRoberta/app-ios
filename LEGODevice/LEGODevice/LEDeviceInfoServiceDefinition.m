//
// Created by Søren Toft Odgaard on 28/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEDeviceInfoServiceDefinition.h"

#define LE_DEVICE_INFO_SERVICE_UUID @"180A"

#define LE_DEVICE_INFO_FIRMWARE_REVISION_CHARACTERISTIC_UUID @"2A26"
#define LE_DEVICE_INFO_HARDWARE_REVISION_CHARACTERISTIC_UUID @"2A27"
#define LE_DEVICE_INFO_SOFTWARE_REVISION_CHARACTERISTIC_UUID @"2A28"
#define LE_DEVICE_INFO_MANUFACTURER_NAME_CHARACTERISTIC_UUID @"2A29"


@implementation LEDeviceInfoServiceDefinition

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
        _UUID = [CBUUID UUIDWithString:LE_DEVICE_INFO_SERVICE_UUID];
        _name = @"DeviceInfoService";

        _firmwareRevision = [LECharacteristicDefinition
                characteristicWithName:@"FirmwareRevision"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:LE_DEVICE_INFO_FIRMWARE_REVISION_CHARACTERISTIC_UUID]
                mandatory:YES
                mandatoryProperties:CBCharacteristicPropertyRead
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _hardwareRevision = [LECharacteristicDefinition
                characteristicWithName:@"HardwareRevision"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:LE_DEVICE_INFO_HARDWARE_REVISION_CHARACTERISTIC_UUID]
                mandatory:NO
                mandatoryProperties:CBCharacteristicPropertyRead
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _softwareRevision = [LECharacteristicDefinition
                characteristicWithName:@"SoftwareRevision"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:LE_DEVICE_INFO_SOFTWARE_REVISION_CHARACTERISTIC_UUID]
                mandatory:YES
                mandatoryProperties:CBCharacteristicPropertyRead
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _manufacturerName = [LECharacteristicDefinition
                characteristicWithName:@"ManufacturerName"
                serviceDefinition:self
                UUID:[CBUUID UUIDWithString:LE_DEVICE_INFO_MANUFACTURER_NAME_CHARACTERISTIC_UUID]
                mandatory:YES
                mandatoryProperties:CBCharacteristicPropertyRead
                recommendedProperties:(CBCharacteristicProperties) 0
                permissions:CBAttributePermissionsReadable
        ];

        _characteristicDefinitions = @[ self.firmwareRevision, self.hardwareRevision, self.softwareRevision, self.manufacturerName ];

    }

    return self;
}


@end