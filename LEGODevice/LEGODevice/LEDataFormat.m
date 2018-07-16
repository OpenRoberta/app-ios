//
// Created by Søren Toft Odgaard on 26/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEDataFormat.h"

@implementation LEDataFormat {

}
- (instancetype)initWithModeName:(NSString *)modeName mode:(uint8_t)modeValue unit:(LEInputFormatUnit)unit numberOfBytes:(uint8_t)numberOfBytes dataSetCount:(uint8_t)numberOfDataSets
{
    self = [super init];
    if (self) {
        _modeName = modeName;
        _mode = modeValue;
        _unit = unit;
        _dataSetSize = numberOfBytes;
        _dataSetCount = numberOfDataSets;
    }

    return self;
}

+ (instancetype)formatWithModeName:(NSString *)modeName mode:(uint8_t)modeValue unit:(LEInputFormatUnit)unit sizeOfDataSet:(uint8_t)numberOfBytes dataSetCount:(uint8_t)numberOfDataSets
{
    return [[self alloc] initWithModeName:modeName mode:modeValue unit:unit numberOfBytes:numberOfBytes dataSetCount:numberOfDataSets];
}

- (NSString *)unitName
{
    switch (self.unit) {
        case LEInputFormatUnitRaw:
            return @"Raw";
        case LEInputFormatUnitPercentage:
            return @"Percentage";
        case LEInputFormatUnitSI:
            return @"SI";
        case LEInputFormatUnitUnknown:
            return @"Unknown";
    }
    return nil;
}

- (NSString *)description
{
    NSMutableString *description = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];
    [description appendFormat:@"mode=%@(%lu)", self.modeName, (unsigned long) self.mode];
    [description appendFormat:@", unit=%@(%lu)", self.unitName, (unsigned long) self.unit];
    [description appendFormat:@", dataSetSize=%i", self.dataSetSize];
    [description appendFormat:@", dataSetCount=%i", self.dataSetCount];
    [description appendString:@">"];
    return description;
}


- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToFormat:other];
}

- (BOOL)isEqualToFormat:(LEDataFormat *)otherFormat
{
    if (self == otherFormat)
        return YES;
    if (otherFormat == nil)
        return NO;
    if (self.unit != otherFormat.unit)
        return NO;
    if (self.mode != otherFormat.mode)
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = (NSUInteger) self.unit;
    hash = hash * 31u + self.mode;
    return hash;
}


@end