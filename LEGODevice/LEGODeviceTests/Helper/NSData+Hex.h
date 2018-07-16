//
// Created by Søren Toft Odgaard on 29/10/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NSData (Hex)
+ (NSData *)dataFromHexString:(NSString *)hexString;
@end