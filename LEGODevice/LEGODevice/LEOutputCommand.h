//
// Created by Søren Toft Odgaard on 07/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEConnectInfo;

@interface LEOutputCommand : NSObject

@property (nonatomic, strong) NSData *data;


#pragma mark - Command Factory Methods

+ (instancetype)commandWriteMotorPower:(int8_t)speed connectID:(uint8_t)connectID;

+ (instancetype)commandWritePiezoToneFrequency:(uint16_t)frequency milliseconds:(uint16_t)milliseconds connectID:(uint8_t)connectID;

+ (instancetype)commandWritePiezoToneStopForConnectID:(uint8_t)connectID;

+ (instancetype)commandWriteRGBLightRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue connectId:(uint8_t)connectID;

+ (instancetype)commandWriteRGBLightIndex:(uint8_t)index connectId:(uint8_t)connectID;

#pragma mark - Generic Initializer

+ (instancetype)commandWithConnectID:(uint8_t)connectID commandID:(uint8_t)commandID payloadData:(NSData *)payloadData;

+ (LEOutputCommand *)commandWithDirectWriteThroughData:(NSData *)data connectID:(uint8_t)connectID;

@end