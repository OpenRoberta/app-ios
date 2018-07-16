//

// Created by Søren Toft Odgaard on 07/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEOutputCommand.h"
#import "LEConnectInfo.h"

static const int8_t kHeaderSize = 3;

static const uint8_t kWriteMotorPowerCommandID = 0x01;

static const uint8_t kPlayPiezoToneCommandID = 0x02;
static const uint8_t kStopPiezoToneCommandID = 0x03;

static const uint8_t kWriteRGBCommandID = 0x04;

static const uint8_t kWriteDirectID = 0x05;

@implementation LEOutputCommand


#pragma mark - Command Factory Methods
+ (instancetype)commandWriteMotorPower:(int8_t)speed connectID:(uint8_t)connectID
{
    return [self commandWithConnectID:connectID commandID:kWriteMotorPowerCommandID payloadData:[NSData dataWithBytes:&speed length:sizeof(speed)]];
}

+ (instancetype)commandWritePiezoToneFrequency:(uint16_t)frequency milliseconds:(uint16_t)milliseconds connectID:(uint8_t)connectID
{
    NSMutableData *payload = [NSMutableData dataWithCapacity:4];
    [payload appendBytes:&frequency length:sizeof(frequency)];
    [payload appendBytes:&milliseconds length:sizeof(milliseconds)];
    return [self commandWithConnectID:connectID commandID:kPlayPiezoToneCommandID payloadData:payload];
}

+ (instancetype)commandWriteRGBLightRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue connectId:(uint8_t)connectID
{
    NSMutableData *payload = [NSMutableData dataWithCapacity:3];
    [payload appendBytes:&red length:sizeof(red)];
    [payload appendBytes:&green length:sizeof(green)];
    [payload appendBytes:&blue length:sizeof(blue)];
    return [self commandWithConnectID:connectID commandID:kWriteRGBCommandID payloadData:payload];
}

+ (instancetype)commandWriteRGBLightIndex:(uint8_t)index connectId:(uint8_t)connectID
{
    NSMutableData *payload = [NSMutableData dataWithCapacity:1];
    [payload appendBytes:&index length:sizeof(index)];
    return [self commandWithConnectID:connectID commandID:kWriteRGBCommandID payloadData:payload];
}

+ (LEOutputCommand *)commandWithDirectWriteThroughData:(NSData *)data connectID:(uint8_t)connectID
{
    return [self commandWithConnectID:connectID commandID:kWriteDirectID payloadData:data];
}


#pragma mark - Generic Initializer
+ (instancetype)commandWritePiezoToneStopForConnectID:(uint8_t)connectID
{
    return [self commandWithConnectID:connectID commandID:kStopPiezoToneCommandID payloadData:nil];
}

+ (instancetype)commandWithConnectID:(uint8_t)connectID commandID:(uint8_t)commandID payloadData:(NSData *)payloadData
{
    return [[self alloc] initWithConnectID:connectID commandID:commandID data:payloadData];
}

- (instancetype)initWithConnectID:(uint8_t)connectID commandID:(uint8_t)commandID data:(NSData *)payloadData
{
    self = [super init];
    if (self) {
        NSMutableData *data = [NSMutableData dataWithCapacity:kHeaderSize + payloadData.length];
        [data appendBytes:&connectID length:sizeof(connectID)];
        [data appendBytes:&commandID length:sizeof(commandID)];
        uint8_t numberOfBytes = (uint8_t) payloadData.length;
        [data appendBytes:&numberOfBytes length:sizeof(numberOfBytes)];
        [data appendData:payloadData];
        _data = data;
    }
    return self;

}



@end