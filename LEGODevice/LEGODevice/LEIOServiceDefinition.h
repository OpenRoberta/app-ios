//
// Created by Søren Toft Odgaard on 14/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEBluetoothServiceDefinition.h"


@interface LEIOServiceDefinition : LEBluetoothServiceDefinition



+ (instancetype)sharedInstance;

@property (readonly) LECharacteristicDefinition *inputValue;

@property (readonly) LECharacteristicDefinition *inputFormat;

@property (readonly) LECharacteristicDefinition *inputCommand;

@property (readonly) LECharacteristicDefinition *outputCommand;


@end