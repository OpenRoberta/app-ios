//
// Created by Søren Toft Odgaard on 28/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LERevision.h"

/**
 Represent info about a connected LEDevice such as firmware-, hardware- and software revision.
*/
@interface LEDeviceInfo : NSObject

/** The firmware revision of a LEDevice */
@property (nonatomic, readonly) LERevision *firmwareRevision;

/** The hardware revision of a LEDevice */
@property (nonatomic, readonly) LERevision *hardwareRevision;

/** The software revision of a LEDevice */
@property (nonatomic, readonly) LERevision *softwareRevision;

/** The manufacturer name of the LEDevice */
@property (nonatomic, readonly) NSString *manufacturerName;

/** @name Check for equality */

/**
 Return YES if this device info is equal to info
 @param info     The device info to check for equality with
*/
- (BOOL)isEqualToInfo:(LEDeviceInfo *)info;

@end

