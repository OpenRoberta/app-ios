//
// Created by Søren Toft Odgaard on 22/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEInputFormat;
@class LEConnectInfo;


@interface LEInputCommand : NSObject

@property (nonatomic, readonly) NSData *data;

+ (LEInputCommand *)commandWriteInputFormat:(LEInputFormat *)format connectID:(uint8_t)connectID;

+ (LEInputCommand *)commandReadInputFormatForConnectID:(uint8_t)connectID;

+ (LEInputCommand *)commandReadValueForConnectID:(uint8_t)connectID;

@end