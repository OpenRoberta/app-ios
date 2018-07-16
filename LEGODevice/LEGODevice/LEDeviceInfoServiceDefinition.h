//
// Created by Søren Toft Odgaard on 28/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEBluetoothServiceDefinition.h"


@interface LEDeviceInfoServiceDefinition : LEBluetoothServiceDefinition

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) LECharacteristicDefinition *firmwareRevision;
@property (nonatomic, readonly) LECharacteristicDefinition *hardwareRevision;
@property (nonatomic, readonly) LECharacteristicDefinition *softwareRevision;
@property (nonatomic, readonly) LECharacteristicDefinition *manufacturerName;

@end