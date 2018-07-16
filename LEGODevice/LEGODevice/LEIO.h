//
// Created by Søren Toft Odgaard on 8/26/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "LEMultiDelegate.h"
#import "LEConnectInfo.h"
#import "LETiltSensor.h"

@class LEInputFormat;


@class LEIO;

@protocol LEIODelegate <NSObject>

- (void)io:(LEIO *)io didReceiveInputFormat:(LEInputFormat *)inputFormat;

- (void)io:(LEIO *)io didReceiveValueData:(NSData *)valueData;

- (LEConnectInfo *)ioDidRequestConnectInfo:(LEIO *)io;

@end


@interface LEIO : NSObject {
@protected
    LEMultiDelegate *_delegates;
}

- (void)writeInputFormat:(LEInputFormat *)inputFormat forConnectID:(uint8_t)connectID;

- (void)readInputFormatForConnectID:(uint8_t)connectID;

- (void)writeMotorPower:(int8_t)power forConnectID:(uint8_t)connectID;

- (void)writeMotorPower:(int8_t)power offset:(int8_t)offset forConnectID:(uint8_t)connectID;

- (void)writePiezoToneFrequency:(uint16_t)frequency milliseconds:(uint16_t)milliseconds connectID:(uint8_t)connectID;

- (void)writePiezoToneStopForConnectID:(uint8_t)connectID;

- (void)writeColorRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue connectID:(uint8_t)connectID;

- (void)writeColorIndex:(uint8_t)index connectID:(uint8_t)connectID;

- (void)writeData:(NSData *)data connectID:(uint8_t)connectID;

- (void)readValueForConnectID:(uint8_t)connectID;

- (void)resetStateForConnectID:(uint8_t)connectID;


- (void)addDelegate:(id<LEIODelegate>)delegate;

- (void)removeDelegate:(id<LEIODelegate>)delegate;

@end
