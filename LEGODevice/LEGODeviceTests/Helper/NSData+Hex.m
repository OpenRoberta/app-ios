//
// Created by Søren Toft Odgaard on 29/10/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//


#import "NSData+Hex.h"


@implementation NSData (Hex)

+ (NSData *)dataFromHexString:(NSString *)hexString {
    hexString = [hexString stringByReplacingOccurrencesOfString:@" " withString:@""];
    hexString = [hexString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [hexString length]/2; i++) {
        byte_chars[0] = [hexString characterAtIndex:i*2];
        byte_chars[1] = [hexString characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    return commandToSend;
}


@end