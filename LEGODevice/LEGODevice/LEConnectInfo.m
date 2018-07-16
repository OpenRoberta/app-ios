//
// Created by Søren Toft Odgaard on 15/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEConnectInfo.h"
#import "LERevision.h"

@interface LEConnectInfo ()
@property (nonatomic, strong) NSMutableArray *validTypes;
@end



@implementation LEConnectInfo

+ (LEConnectInfo *)connectInfoWithConnectID:(uint8_t)connectId hubIndex:(uint8_t)hubIndex type:(uint8_t)type
{
    return [[self alloc] initWithConnectID:connectId hubIndex:hubIndex type:type hardwareVersion:0 firmwareVersion:0];
}

+ (LEConnectInfo *)connectInfoWithConnectID:(uint8_t)connectId hubIndex:(uint8_t)hubIndex type:(uint8_t)type hardwareVersion:(LERevision *)hwVersion firmwareVersion:(LERevision *)fwVersion
{
    return [[LEConnectInfo alloc] initWithConnectID:connectId hubIndex:hubIndex type:type hardwareVersion:hwVersion firmwareVersion:fwVersion];
}

- (instancetype)initWithConnectID:(uint8_t)identifier hubIndex:(uint8_t)hubIndex type:(uint8_t)type hardwareVersion:(LERevision *)hwVersion firmwareVersion:(LERevision *)fwVersion
{
    self = [super init];
    if (self) {
        _connectID = identifier;
        _hubIndex = hubIndex;
        _type = type;
        _hardwareVersion = hwVersion;
        _firmwareVersion = fwVersion;

        [self populateValidTypes];
    }
    return self;
}


- (void)populateValidTypes
{
    self.validTypes = [NSMutableArray array];
    LEIOType ioType = LEIOTypeMotor;

    //We use a enum with fall-through (no break statements) to make sure we get all types
    //this will also give a compile warning if a new type is added that is not in the cases below
    switch (ioType) {
            case LEIOTypeMotor:
                [self.validTypes addObject:@(LEIOTypeMotor)];
            case LEIOTypeVoltage:
                [self.validTypes addObject:@(LEIOTypeVoltage)];
            case LEIOTypeCurrent:
                [self.validTypes addObject:@(LEIOTypeCurrent)];
            case LEIOTypePiezoTone:
                [self.validTypes addObject:@(LEIOTypePiezoTone)];
            case LEIOTypeRGBLight:
                [self.validTypes addObject:@(LEIOTypeRGBLight)];
            case LEIOTypeTiltSensor:
                [self.validTypes addObject:@(LEIOTypeTiltSensor)];
            case LEIOTypeMotionSensor:
                [self.validTypes addObject:@(LEIOTypeMotionSensor)];
            case LEIOTypeGeneric:
                [self.validTypes addObject:@(LEIOTypeGeneric)];
        }
}

- (NSString *)typeString
{
    return [LEConnectInfo stringFromInputType:self.typeEnum];
}

- (LEIOType)typeEnum
{
    if ([self.validTypes containsObject:@(self.type)]) {
        return (LEIOType) self.type;
    } else {
        return LEIOTypeGeneric;
    }
}


+ (NSString *)stringFromInputType:(LEIOType)type
{
    switch (type) {
        case LEIOTypeGeneric:
            return @"LEIOTypeGeneric";
        case LEIOTypeMotionSensor:
            return @"LEIOTypeMotionSensor";
        case LEIOTypeTiltSensor:
            return @"LEIOTypeTiltSensor";
        case LEIOTypePiezoTone:
            return @"LEIOTypePiezoTone";
        case LEIOTypeMotor:
            return @"LEIOTypeMotor";
        case LEIOTypeCurrent:
            return @"LEIOTypeCurrent";
        case LEIOTypeVoltage:
            return @"LEIOTypeVoltage";
        case LEIOTypeRGBLight:
            return @"LEIOTypeRGBLight";
    }
    return @"LEIOTypeGeneric";
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToConnectInfo:other];
}

- (BOOL)isEqualToConnectInfo:(LEConnectInfo *)info
{
    if (self == info)
        return YES;
    if (info == nil)
        return NO;
    if (self.connectID != info.connectID)
        return NO;
    if (self.hubIndex != info.hubIndex)
        return NO;
    if (self.type != info.type)
        return NO;
    if (self.hardwareVersion != info.hardwareVersion && ![self.hardwareVersion isEqualToRevision:info.hardwareVersion])
        return NO;
    if (self.firmwareVersion != info.firmwareVersion && ![self.firmwareVersion isEqualToRevision:info.firmwareVersion])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = self.connectID;
    hash = hash * 31u + self.hubIndex;
    hash = hash * 31u + self.type;
    hash = hash * 31u + [self.hardwareVersion hash];
    hash = hash * 31u + [self.firmwareVersion hash];
    return hash;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"ID: %ld, HUB: %ld, Type: %ld (%@)",
                                      (long) self.connectID, (long) self.hubIndex, (long) self.type, self.typeString];
}

- (NSString *)debugDescription
{
    return [self description];
}

@end
