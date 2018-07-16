//
// Created by Søren Toft Odgaard on 27/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEBluetoothServiceDefinition.h"


@interface LEBatteryServiceDefinition : LEBluetoothServiceDefinition

+ (instancetype)sharedInstance;

@property (readonly) LECharacteristicDefinition *batteryLevel;

@end