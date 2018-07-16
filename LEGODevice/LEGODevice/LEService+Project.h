//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEService.h"
#import "LEIO.h"

@interface LEService (Project) <LEIODelegate>

- (instancetype)initWithConnectInfo:(LEConnectInfo *)connectInfo io:(LEIO *)io;

+ (instancetype)serviceWithConnectInfo:(LEConnectInfo *)connectInfo io:(LEIO *)io;

@property (nonatomic, readonly) LEIO *io;

@property (nonatomic, strong) LEMultiDelegate *delegates;

- (void)setDevice:(LEDevice *)device;

- (BOOL)verifyData:(NSData *)data error:(NSError **)error;

- (BOOL)handleUpdatedValueData:(NSData *)valueData error:(NSError **)error;

- (void)handleUpdatedInputFormat:(LEInputFormat *)inputFormat;

- (int32_t)integerFromData:(NSData *)data;

- (Float32)floatFromData:(NSData *)data;

@end