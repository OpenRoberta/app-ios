//
// Created by Søren Toft Odgaard on 02/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEIO.h"


@interface LEIOStub : LEIO

@property (nonatomic, readonly) int8_t lastWrittenMotorPower;
@property (nonatomic, readonly) uint16_t lastPiezoFrequencyWritten;
@property (nonatomic, readonly) uint16_t lastPiezoMillisecondsWritten;


@end