//
// Created by Søren Toft Odgaard on 10/06/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LERevision.h"


@implementation LERevision


+ (instancetype)revisionWithString:(NSString *)revisionString
{
    return [[self alloc] initWithRevisionString:revisionString];
}

+ (instancetype)revisionWithData:(NSData *)revisionData
{
    return [[self alloc] initWithData:revisionData];
}

- (instancetype)initWithRevisionString:(NSString *)revisionString
{
    self = [super init];
    if (self) {
        [self parseRevision:revisionString];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)revisionData
{
    self = [super init];
    if (self) {
        Byte *bytes = (Byte *) revisionData.bytes;
        if (revisionData.length >= 1) {
            _majorVersion = bytes[0];
        }
        if (revisionData.length >= 2) {
            _minorVersion = bytes[1];
        }
        if (revisionData.length >= 3) {
            _bugFixVersion = bytes[2];
        }
        if (revisionData.length >= 4) {
            _buildNumber = bytes[3];
        }
    }
    return self;
}


- (void)parseRevision:(NSString *)revision
{
    NSCharacterSet *validCharactersSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSRange range = [revision rangeOfCharacterFromSet:[validCharactersSet invertedSet]];
    if (range.location == NSNotFound) {
        NSArray *versionComponents = [revision componentsSeparatedByString:@"."];
        if (versionComponents.count >= 1) {
            _majorVersion = ((NSString *) versionComponents[0]).integerValue;
        }
        if (versionComponents.count >= 2) {
            _minorVersion = ((NSString *) versionComponents[1]).integerValue;
        }
        if (versionComponents.count >= 3) {
            _bugFixVersion = ((NSString *) versionComponents[2]).integerValue;
        }
        if (versionComponents.count >= 4) {
            _buildNumber = ((NSString *) versionComponents[3]).integerValue;
        }
    } else {
        //If string contains anything but numbers and '.' then set all properties to zero
        _majorVersion = 0;
        _minorVersion = 0;
        _bugFixVersion = 0;
        _buildNumber = 0;
    }

}

- (NSString *)stringRepresentation
{
    return [NSString stringWithFormat:@"%lu.%lu.%lu.%lu",
                                      (unsigned long) self.majorVersion, (unsigned long) self.minorVersion, (unsigned long) self.bugFixVersion, (unsigned long) self.buildNumber];

}

- (NSString *)description
{
    return self.stringRepresentation;
}

#pragma mark - Equals and Hash
- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToRevision:other];
}

- (BOOL)isEqualToRevision:(LERevision *)otherRevision
{
    if (self == otherRevision)
        return YES;
    if (otherRevision == nil)
        return NO;
    if (self.majorVersion != otherRevision.majorVersion)
        return NO;
    if (self.minorVersion != otherRevision.minorVersion)
        return NO;
    if (self.bugFixVersion != otherRevision.bugFixVersion)
        return NO;
    if (self.buildNumber != otherRevision.buildNumber)
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    NSUInteger hash = self.majorVersion;
    hash = hash * 31u + self.minorVersion;
    hash = hash * 31u + self.bugFixVersion;
    hash = hash * 31u + self.buildNumber;
    return hash;
}



@end
