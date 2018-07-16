//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LEService;
@class LEConnectInfo;
@class LEIO;
@class LEBluetoothDevice;
@class LEDevice;


@interface LEServiceFactory : NSObject

+ (LEService *)serviceWithConnectInfo:(LEConnectInfo *)connectInfo io:(LEIO *)io device:(LEDevice *)device;

@end