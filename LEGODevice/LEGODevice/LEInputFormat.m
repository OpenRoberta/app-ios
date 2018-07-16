//
// Created by Søren Toft Odgaard on 22/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEInputFormat.h"
#import "LELogger+Project.h"
#import "LEIO.h"

static NSUInteger inputFormatPackageSize = 11;

@interface LEInputFormat ()

@property (nonatomic, readwrite) uint8_t revision;
@property (nonatomic, readwrite) uint8_t connectID;
@property (nonatomic, readwrite) uint8_t typeID;
@property (nonatomic, readwrite) uint8_t mode;
@property (nonatomic, readwrite) uint32_t deltaInterval;
@property (nonatomic, readwrite) LEInputFormatUnit unit;
@property (nonatomic, readwrite, getter=isNotificationsEnabled) BOOL notificationsEnabled;
@property (nonatomic, readwrite) uint8_t numberOfBytes;

@end

@implementation LEInputFormat

+ (instancetype)inputFormatWithData:(NSData *)data
{
    return [[LEInputFormat alloc] initWithData:data];

}

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self) {
        if (data == nil) {
            LEErrorLog(@"Cannot instantiate LEInputFormat from nil format NSData");
            return nil;
        }

        //first byte is for the revision number, the rest of the bytes should be one or more input format sub-packages.
        if (data.length != inputFormatPackageSize) {
            LEErrorLog(@"Cannot create LEInputFormat from package with size %ld, expected size to be %ld",
            (long) data.length, (long) inputFormatPackageSize);
            return nil;
        }

        Byte *bytes = (Byte*) data.bytes;
        NSUInteger byteIndex = 0;
        _revision = bytes[byteIndex];
        byteIndex += sizeof(_revision);

        _connectID = bytes[byteIndex];
        byteIndex += sizeof(_connectID);

        _typeID = bytes[byteIndex];
        byteIndex += sizeof(_typeID);

        _mode = bytes[byteIndex];
        byteIndex += sizeof(_mode);

        memcpy(&_deltaInterval, bytes+byteIndex, sizeof(_deltaInterval));
        byteIndex += sizeof(_deltaInterval);

        _unit = (LEInputFormatUnit) bytes[byteIndex];
        byteIndex += sizeof(_unit);

        _notificationsEnabled = (bytes[byteIndex] == 1);
        byteIndex += sizeof(_notificationsEnabled);

        _numberOfBytes = bytes[byteIndex];
    }
    return self;
}

- (instancetype)initWithConnectID:(uint8_t)connectID
                           typeID:(uint8_t)typeID
                             mode:(uint8_t)mode
                    deltaInterval:(uint32_t)deltaInterval
                             unit:(LEInputFormatUnit)unit
             notificationsEnabled:(BOOL)notificationsEnabled
{
    self = [super init];
    if (self) {
        _connectID = connectID;
        _typeID = typeID;
        _mode = mode;
        _deltaInterval = deltaInterval;
        _unit = unit;
        _notificationsEnabled = notificationsEnabled;
    }

    return self;
}

+ (instancetype)inputFormatWithConnectID:(uint8_t)connectID
                                  typeID:(uint8_t)typeID
                                    mode:(uint8_t)mode
                           deltaInterval:(uint32_t)deltaInterval
                                    unit:(LEInputFormatUnit)unit
                    notificationsEnabled:(BOOL)notificationsEnabled;
{
    return [[self alloc] initWithConnectID:connectID typeID:typeID mode:mode deltaInterval:deltaInterval unit:unit notificationsEnabled:notificationsEnabled];
}

- (instancetype)inputFormatBySettingMode:(uint8_t)mode
{
    return [LEInputFormat inputFormatWithConnectID:self.connectID typeID:self.typeID mode:mode deltaInterval:self.deltaInterval unit:self.unit notificationsEnabled:self.notificationsEnabled];
}

- (instancetype)inputFormatBySettingMode:(uint8_t)mode unit:(LEInputFormatUnit)unit
{
    return [LEInputFormat inputFormatWithConnectID:self.connectID typeID:self.typeID mode:mode deltaInterval:self.deltaInterval unit:unit notificationsEnabled:self.notificationsEnabled];
}

- (instancetype)inputFormatBySettingDeltaInterval:(uint32_t)deltaInterval
{
    return [LEInputFormat inputFormatWithConnectID:self.connectID typeID:self.typeID mode:self.mode deltaInterval:deltaInterval unit:self.unit  notificationsEnabled:self.notificationsEnabled];
}

- (instancetype)inputFormatBySettingNotificationsEnabled:(BOOL)enabled
{
    return [LEInputFormat inputFormatWithConnectID:self.connectID typeID:self.typeID mode:self.mode deltaInterval:self.deltaInterval unit:self.unit notificationsEnabled:enabled];
}

- (NSMutableData *)writeFormatData {
    NSMutableData *writeData = [NSMutableData dataWithCapacity:8];
    [writeData appendBytes:&_typeID length:sizeof(_typeID)];
    [writeData appendBytes:&_mode length:sizeof(_mode)];
    [writeData appendBytes:&_deltaInterval length:sizeof(_deltaInterval)];
    [writeData appendBytes:&_unit length:sizeof(_unit)];
    uint8_t notifications = (uint8_t) (self.notificationsEnabled?  1 : 0);
    [writeData appendBytes:&notifications length:sizeof(notifications)];

    return writeData;
}


#pragma mark - Description
- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"revision=%ld", (long)self.revision];
    [description appendFormat:@", connectID=%ld", (long)self.connectID];
    [description appendFormat:@", typeID=%ld", (long)self.typeID];
    [description appendFormat:@", mode=%ld", (long)self.mode];
    [description appendFormat:@", deltaInterval=%ld", (long)self.deltaInterval];
    [description appendFormat:@", unit=%ld", (long)self.unit];
    [description appendFormat:@", notificationsEnabled=%@", self.notificationsEnabled? @"YES" : @"NO"];
    [description appendFormat:@", numberOfBytes=%ld", (long)self.numberOfBytes];
    [description appendString:@">"];
    return description;
}

- (NSString *)debugDescription
{
    return [self description];
}


#pragma mark - Equals and Hash

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToFormat:other];
}

- (BOOL)isEqualToFormat:(LEInputFormat *)otherFormat
{
    if (self == otherFormat)
        return YES;
    if (otherFormat == nil)
        return NO;
    if (self.revision != otherFormat.revision)
        return NO;
    if (self.connectID != otherFormat.connectID)
        return NO;
    if (self.typeID != otherFormat.typeID)
        return NO;
    if (self.mode != otherFormat.mode)
        return NO;
    if (self.deltaInterval != otherFormat.deltaInterval)
        return NO;
    if (self.unit != otherFormat.unit)
        return NO;
    if (self.notificationsEnabled != otherFormat.notificationsEnabled)
        return NO;
    if (self.numberOfBytes != otherFormat.numberOfBytes)
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = self.revision;
    hash = hash * 31u + self.connectID;
    hash = hash * 31u + self.typeID;
    hash = hash * 31u + self.mode;
    hash = hash * 31u + self.deltaInterval;
    hash = hash * 31u + (NSUInteger) self.unit;
    hash = hash * 31u + self.notificationsEnabled;
    hash = hash * 31u + self.numberOfBytes;
    return hash;
}

@end