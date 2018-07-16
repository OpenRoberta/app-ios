//
// Created by Søren Toft Odgaard on 22/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEInputFormat.h"

@interface LEInputFormat (Project)

#pragma mark - Create a LEInputFormat from data received from the device


// Return an dictionary from ConnectID to LEInputFormat.
//
// The data must have the format
// Byte    0 : Revision
// Byte  1-9 : Input Format Data 1
//
+ (instancetype)inputFormatWithData:(NSData *)data;

- (NSMutableData *)writeFormatData;

@end