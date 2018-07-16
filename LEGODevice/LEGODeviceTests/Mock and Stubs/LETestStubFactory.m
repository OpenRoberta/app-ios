//
// Created by Søren Toft Odgaard on 02/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETestStubFactory.h"


@implementation LETestStubFactory {

}

+ (NSData *)inputFormatWriteDataWithRevision:(uint8_t)revision
                                   connectID:(uint8_t)connectID
                                      typeID:(uint8_t)typeID
                                        mode:(uint8_t)mode
                               deltaInterval:(uint32_t)deltaInterval
                                        unit:(uint8_t)unit
                        notificationsEnabled:(uint8_t)enabled
                               numberOfBytes:(uint8_t)nmbOfBytes
{
    NSMutableData *data = [NSMutableData dataWithCapacity:11];
    [data appendBytes:&revision length:sizeof(revision)];
    [data appendBytes:&connectID length:sizeof(connectID)];
    [data appendBytes:&typeID length:sizeof(typeID)];
    [data appendBytes:&mode length:sizeof(mode)];
    [data appendBytes:&deltaInterval length:sizeof(deltaInterval)];
    [data appendBytes:&unit length:sizeof(unit)];
    [data appendBytes:&enabled length:sizeof(enabled)];
    [data appendBytes:&nmbOfBytes length:sizeof(nmbOfBytes)];
    return data;
}


@end