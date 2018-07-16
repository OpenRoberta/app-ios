    //
// Created by Søren Toft Odgaard on 15/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEBluetoothServiceDefinition.h"


@interface LEDeviceServiceDefinition : LEBluetoothServiceDefinition

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) CBUUID *shortServiceUUID;

@property (nonatomic, readonly) LECharacteristicDefinition *deviceName;

@property (nonatomic, readonly) LECharacteristicDefinition *attachedIO;

@property (nonatomic, readonly) LECharacteristicDefinition *deviceButton;

@property (nonatomic, readonly) LECharacteristicDefinition *lowVoltageAlert;


@end