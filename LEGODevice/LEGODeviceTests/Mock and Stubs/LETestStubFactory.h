//
// Created by Søren Toft Odgaard on 02/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LETestStubFactory : NSObject

+ (NSData *)inputFormatWriteDataWithRevision:(uint8_t)revision
                                   connectID:(uint8_t)connectID
                                      typeID:(uint8_t)typeID
                                        mode:(uint8_t)mode
                               deltaInterval:(uint32_t)deltaInterval
                                        unit:(uint8_t)unit
                        notificationsEnabled:(uint8_t)enabled
                               numberOfBytes:(uint8_t)nmbOfBytes;

@end