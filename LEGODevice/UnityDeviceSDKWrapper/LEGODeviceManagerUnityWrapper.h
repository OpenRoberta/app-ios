//
//  LEGODeviceUnityWrapper.h
//  Unity-iPhone
//
//  Created by Kim Jung Nissen on 10/09/14.
//
//

#import <LEGODevice/LEGODevice.h>

@interface LEGODeviceManagerUnityWrapper : NSObject <LEDeviceManagerDelegate>

+ (instancetype)sharedInstance;

- (LEDevice *)deviceWithDeviceID:(NSString *)legoDeviceID;
- (LEService *)serviceWithDeviceID:(NSString *)legoDeviceID connectID:(NSString *)connectID;

@end
