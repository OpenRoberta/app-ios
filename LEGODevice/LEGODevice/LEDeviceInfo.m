//
// Created by Søren Toft Odgaard on 28/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEDeviceInfo.h"
#import "LERevision+Project.h"

@implementation LEDeviceInfo

+ (instancetype)deviceInfo
{
    return [[self alloc] init];
}

- (instancetype)deviceInfoBySettingFirmwareRevisionString:(NSString *)revision
{
    LEDeviceInfo *newInfo = [self copy];
    newInfo->_firmwareRevision = [LERevision revisionWithString:revision];
    return newInfo;
}

- (instancetype)deviceInfoBySettingHardwareRevisionString:(NSString *)revision
{
    LEDeviceInfo *newInfo = [self copy];
    newInfo->_hardwareRevision = [LERevision revisionWithString:revision];
    return newInfo;
}

- (instancetype)deviceInfoBySettingSoftwareRevisionString:(NSString *)revision
{
    LEDeviceInfo *newInfo = [self copy];
    newInfo->_softwareRevision = [LERevision revisionWithString:revision];
    return newInfo;
}

- (instancetype)deviceInfoBySettingManufactureName:(NSString *)name
{
    LEDeviceInfo *newInfo = [self copy];
    newInfo->_manufacturerName = name;
    return newInfo;
}

- (BOOL)isComplete
{
    //Hardware revision not mandatory
    return (self.firmwareRevision /* && self.hardwareRevision */ && self.softwareRevision && self.manufacturerName);
}

- (id)copyWithZone:(NSZone *)zone
{
    LEDeviceInfo *copy = [[[self class] allocWithZone:zone] init];

    if (copy != nil) {
        copy->_firmwareRevision = _firmwareRevision;
        copy->_hardwareRevision = _hardwareRevision;
        copy->_softwareRevision = _softwareRevision;
        copy->_manufacturerName = _manufacturerName;
    }

    return copy;
}


- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToInfo:other];
}

- (BOOL)isEqualToInfo:(LEDeviceInfo *)info
{
    if (self == info)
        return YES;
    if (info == nil)
        return NO;
    if (self.firmwareRevision != info.firmwareRevision && ![self.firmwareRevision isEqualToRevision:info.firmwareRevision])
        return NO;
    if (self.hardwareRevision != info.hardwareRevision && ![self.hardwareRevision isEqualToRevision:info.hardwareRevision])
        return NO;
    if (self.softwareRevision != info.softwareRevision && ![self.softwareRevision isEqualToRevision:info.softwareRevision])
        return NO;
    if (self.manufacturerName != info.manufacturerName && ![self.manufacturerName isEqualToString:info.manufacturerName])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = [self.firmwareRevision hash];
    hash = hash * 31u + [self.hardwareRevision hash];
    hash = hash * 31u + [self.softwareRevision hash];
    hash = hash * 31u + [self.manufacturerName hash];
    return hash;
}


@end