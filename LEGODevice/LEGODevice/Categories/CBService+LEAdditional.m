//
// Created by Søren Toft Odgaard on 23/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "CBService+LEAdditional.h"
#import "LEBluetoothServiceDefinition.h"


@implementation CBService (LEAdditional)

- (NSString *)descriptionWithName
{
    LEBluetoothServiceDefinition *serviceDefinition = [LEBluetoothServiceDefinition serviceDefinitionWithUUID:self.UUID];
    if (serviceDefinition) {
        return serviceDefinition.shortDescription;
    } else {
        return self.UUID.data.description;
    }
}

@end