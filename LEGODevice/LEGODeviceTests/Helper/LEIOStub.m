//
// Created by Søren Toft Odgaard on 02/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEIOStub.h"
#import "LEInputFormat.h"


@implementation LEIOStub

- (void)readValueForConnectID:(uint8_t)connectID
{
    //do nothing
}

- (void)writeInputFormat:(LEInputFormat *)inputFormat forConnectID:(uint8_t)connectID
{
    //Assume that the update went well, and return the 'updated' inputFormat right away
    [_delegates foreachPerform:@selector(io:didReceiveInputFormat:) withObject:self withObject:inputFormat];
}


- (void)readInputFormatForConnectID:(uint8_t)connectID
{
    //do nothing
}

- (void)resetStateForConnectID:(uint8_t)connectID
{
    //do nothing
}

- (void)writeMotorPower:(int8_t)power offset:(int8_t)offset forConnectID:(uint8_t)connectID
{
    _lastWrittenMotorPower = power;

}

- (void)writeMotorPower:(int8_t)power forConnectID:(uint8_t)connectID
{
    _lastWrittenMotorPower = power;
}

- (void)writePiezoToneFrequency:(uint16_t)frequency milliseconds:(uint16_t)milliseconds connectID:(uint8_t)connectID
{
    _lastPiezoFrequencyWritten = frequency;
    _lastPiezoMillisecondsWritten = milliseconds;
}

- (void)writePiezoToneStopForConnectID:(uint8_t)connectID
{
    //do nothing
}

- (void)writeColorRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue connectID:(uint8_t)connectID
{
    //do nothing
}

- (void)writeColorIndex:(uint8_t)index connectID:(uint8_t)connectID
{
    //do nothing
}

- (void)writeData:(NSData *)data connectID:(uint8_t)connectID
{
    //do nothing
}


@end