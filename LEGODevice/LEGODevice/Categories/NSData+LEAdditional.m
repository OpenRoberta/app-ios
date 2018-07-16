//
//  NSData+LEAdditional.m
//  LEGODevice
//
//  Created by Søren Toft Odgaard on 20/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "NSData+LEAdditional.h"
#import "LELogger+Project.h"

@implementation NSData (LEAdditional)

- (NSData *)dataByTrimmingAllBytesFromFirstZero
{
    Byte zero = 0x00;
    NSRange range = [self rangeOfData:[NSData dataWithBytes:&zero length:1] options:0 range:NSMakeRange(0, self.length)];
    NSData *trimmedData;
    if (range.location != NSNotFound) {
        trimmedData = [self subdataWithRange:NSMakeRange(0, range.location)];
    } else {
        trimmedData = self;
    }
    return trimmedData;
}


- (void)enumerateInChuncksOfSize:(NSUInteger)chunckSize
                      withBlock:(void (^)(Byte *chunk, BOOL *stop))block {
    NSUInteger dataSize = self.length;
    if (dataSize % chunckSize != 0) {
        LEWarnLog(@"Data with length: %lx cannot be divided in chunks of size %lx", (long) dataSize, (long)chunckSize);
        return;
    }
    
    Byte *bytes = (Byte *) self.bytes;
    BOOL stop = NO;
    for (int i = 0; (i < dataSize) && !stop; i += chunckSize) {
        block(bytes + i, &stop);
    }
}

- (NSData *)dataByAppendingData:(NSData *)data {
    NSMutableData *mutableData = [self mutableCopy];
    [mutableData appendData:data];
    return mutableData;
}


@end
