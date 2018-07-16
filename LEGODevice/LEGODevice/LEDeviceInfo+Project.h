//
// Created by Søren Toft Odgaard on 29/07/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEDeviceInfo.h"

@interface LEDeviceInfo (Project) <NSCopying>

+ (instancetype)deviceInfo;

- (instancetype)deviceInfoBySettingFirmwareRevisionString:(NSString *)revision;
- (instancetype)deviceInfoBySettingHardwareRevisionString:(NSString *)revision;
- (instancetype)deviceInfoBySettingSoftwareRevisionString:(NSString *)revision;
- (instancetype)deviceInfoBySettingManufactureName:(NSString *)name;

@property (nonatomic, readonly, getter=isComplete) BOOL complete;

@end