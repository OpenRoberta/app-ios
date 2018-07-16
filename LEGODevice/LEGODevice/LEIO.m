//
// Created by Søren Toft Odgaard on 07/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEIO.h"
#import "LEInputFormat.h"


@implementation LEIO

- (void)readValueForConnectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)resetStateForConnectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)writeInputFormat:(LEInputFormat *)inputFormat forConnectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)readInputFormatForConnectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)writeMotorPower:(int8_t)power offset:(int8_t)offset forConnectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)writeMotorPower:(int8_t)power forConnectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)writePiezoToneFrequency:(uint16_t)frequency milliseconds:(uint16_t)milliseconds connectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)writePiezoToneStopForConnectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)writeColorRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue connectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)writeColorIndex:(uint8_t)index connectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

- (void)writeData:(NSData *)data connectID:(uint8_t)connectID
{
    NSAssert(false, @"Must be overwritten by subclass");
}

#pragma mark - Add and Remove Delgates
- (void)addDelegate:(id <LEIODelegate>)delegate
{
    NSParameterAssert(delegate);
    if (!_delegates) {
        _delegates = [[LEMultiDelegate alloc] init];
    }
    [_delegates addDelegate:delegate];
}


- (void)removeDelegate:(id <LEIODelegate>)delegate
{
    NSParameterAssert(delegate);
    [_delegates removeDelegate:delegate];
}



@end