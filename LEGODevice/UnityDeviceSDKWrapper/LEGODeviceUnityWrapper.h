//
//  LEGODeviceUnityWrapper.m
//  Unity-iPhone
//
//  Created by Kim Jung Nissen on 18/09/14.
//
//

#import <LEGODevice/LEGODevice.h>

@interface LEGODeviceUnityWrapper : NSObject <LEDeviceDelegate>

+ (instancetype)sharedInstance;

@end