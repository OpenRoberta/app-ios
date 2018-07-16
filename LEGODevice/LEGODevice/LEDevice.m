//
// Created by Søren Toft Odgaard on 9/6/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "LELogger+Project.h"
#import "LEMultiDelegate.h"
#import "LEDevice.h"

@interface  LEDevice ()
@end

@implementation LEDevice {
}

- (id)init
{
    self = [super init];
    if (self) {
        _delegates = [[LEMultiDelegate alloc] init];
    }
    return self;
}


- (void)addDelegate:(id <LEDeviceDelegate>)delegate
{
    if (delegate) {
        [_delegates addDelegate:delegate];
    } else {
        LEWarnLog(@"Ignoring attempt to add nil delegate to LEDevice");
    }
}


- (void)removeDelegate:(id <LEDeviceDelegate>)delegate
{
    if (delegate) {
        [_delegates removeDelegate:delegate];
    } else {
        LEWarnLog(@"Ignoring attempt to remove nil delegate from LEDevice");
    }
}

- (NSArray *)internalServices
{
    return [self servicesInternal:YES];
}

- (NSArray *)externalServices
{
    return [self servicesInternal:NO];
}

- (NSArray *)servicesInternal:(BOOL)internal
{
    return [self.services filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"isInternalService", @(internal)]];
}

#pragma  mark - Properties

- (NSString *)deviceId {
    return @"Undefined";
}

- (LEDeviceState)connectState {
    return LEDeviceStateDisconnectedNotAdvertising;
}

#pragma mark - Equals and Hashcode

- (BOOL)isEqualToDevice:(LEDevice *)otherDevice
{
    return [super isEqual:otherDevice];
}

@end