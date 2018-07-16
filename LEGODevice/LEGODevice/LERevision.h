//
// Created by Søren Toft Odgaard on 10/06/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Holds revision info to represent for example the hardware and firmware revisions
 of a device and attached IOs (services).
*/
@interface LERevision : NSObject

/** A formatted string representation of the revision */
@property (nonatomic, readonly) NSString *stringRepresentation;

/** The major version number */
@property (nonatomic, readonly) NSUInteger majorVersion;

/** The minor version number */
@property (nonatomic, readonly) NSUInteger minorVersion;

/** The bug fix version number */
@property (nonatomic, readonly) NSUInteger bugFixVersion;

/** The build number */
@property (nonatomic, readonly) NSUInteger buildNumber;


/** @name Check for equality */

/**
 Return YES if this revision is equal to otherRevision
 @param otherRevision     The revision to check for equality with
*/
- (BOOL)isEqualToRevision:(LERevision *)otherRevision;


@end