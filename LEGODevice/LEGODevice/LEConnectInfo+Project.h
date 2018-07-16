//
// Created by Søren Toft Odgaard on 29/07/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEConnectInfo.h"

@interface LEConnectInfo (Project)

+ (LEConnectInfo *)connectInfoWithConnectID:(uint8_t)identifier hubIndex:(uint8_t)hubIndex type:(uint8_t)type;

+ (LEConnectInfo *)connectInfoWithConnectID:(uint8_t)identifier hubIndex:(uint8_t)hubIndex type:(uint8_t)type hardwareVersion:(LERevision *)hwVersion firmwareVersion:(LERevision *)fwVersion;

@end