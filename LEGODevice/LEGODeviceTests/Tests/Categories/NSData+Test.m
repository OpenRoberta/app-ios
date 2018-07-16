//
// Created by Søren Toft Odgaard on 27/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "NSData+Test.h"


@implementation NSData (Test)

+ (NSData *)dataWithFloat1:(Float32)value1
{
    return [NSData dataWithBytes:&value1 length:sizeof(value1)];
}

+ (NSData *)dataWithFloat1:(Float32)value1 float2:(Float32)value2
{
    NSMutableData *data = [NSMutableData dataWithCapacity:8];
    [data appendBytes:&value1 length:sizeof(value1)];
    [data appendBytes:&value2 length:sizeof(value2)];
    return data;
}


@end