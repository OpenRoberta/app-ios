//
// Created by Søren Toft Odgaard on 22/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEInputCommand.h"
#import "LEInputFormat.h"
#import "LEConnectInfo.h"
#import "LEInputFormat+Project.h"


static const int CommandIDInputValue = 0;
static const int CommandIDInputFormat = 1;

//static const int CommandTypeClear = 0;
static const int CommandTypeRead = 1;
static const int CommandTypeWrite = 2;

@implementation LEInputCommand

- (id)initWithCommandID:(uint8_t)commandID commandType:(uint8_t)commandType connectID:(uint8_t)connectID data:(NSData *)payloadData {
    self = [super init];
    if (self) {
        NSMutableData *data = [NSMutableData dataWithCapacity:(3 + payloadData.length)];
        [data appendBytes:&commandID length:sizeof(commandID)];
        [data appendBytes:&commandType length:sizeof(commandType)];
        [data appendBytes:&connectID length:sizeof(connectID)];
        if (payloadData) {
            [data appendData:payloadData];
        }
        _data = data;
    }
    return self;
}


+ (LEInputCommand *)commandWriteInputFormat:(LEInputFormat *)format connectID:(uint8_t)connectID
{
    return [[self alloc] initWithCommandID:CommandIDInputFormat commandType:CommandTypeWrite connectID:connectID data:format.writeFormatData];
}

+ (LEInputCommand *)commandReadInputFormatForConnectID:(uint8_t)connectID
{
    return [[self alloc] initWithCommandID:CommandIDInputFormat commandType:CommandTypeRead connectID:connectID data:nil];
}

+ (LEInputCommand *)commandReadValueForConnectID:(uint8_t)connectID
{
    return [[self alloc] initWithCommandID:CommandIDInputValue commandType:CommandTypeRead connectID:connectID data:nil];
}

@end