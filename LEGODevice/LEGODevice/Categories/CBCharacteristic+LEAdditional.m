//
// Created by Søren Toft Odgaard on 14/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "CBCharacteristic+LEAdditional.h"
#import "LEBluetoothServiceDefinition.h"


@implementation CBCharacteristic (LEAdditional)


- (NSString *)descriptionWithName
{
    LEBluetoothServiceDefinition *serviceDefinition = [LEBluetoothServiceDefinition serviceDefinitionWithUUID:self.service.UUID];
    LECharacteristicDefinition *characteristicDefinition = [serviceDefinition characteristicDefinitionWithUUID:self.UUID];

    if (characteristicDefinition) {
        return characteristicDefinition.shortDescription;
    } else {
        return self.UUID.data.description;
    }
}




@end