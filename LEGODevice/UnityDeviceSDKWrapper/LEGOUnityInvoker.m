//
//  UnityInvoker.m
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 31/03/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import "LEGOUnityInvoker.h"
#import "LEGOWrapperSerialization.h"
#import "LELogger+Project.h"
#import "LEGOWrapperUtils.h"

#if TARGET_OS_IPHONE
    extern void UnitySendMessage(const char* obj, const char* method, const char* msg);
#else
    #import "UnityOSXBridge.h"
    #define UnitySendMessage(class, method, msg) LEGODeviceSDK_OSX_SendMessageToUnity(class, method, msg)
#endif

@implementation LEGOUnityInvoker

+ (void)invokeMethod:(NSString const *)unityMethodName withData:(NSDictionary *)dataDictionary
{
    NSParameterAssert(unityMethodName.length > 0);
    NSParameterAssert(dataDictionary == nil || [dataDictionary isKindOfClass:[NSDictionary class]]);
    
    LEVerboseLog(@"Invoking Unity method on LEGODeviceManager: %@ with data: %@", unityMethodName, dataDictionary);
    
    NSString *dataString;
    if (dataDictionary != nil) {
        dataString = [LEGOWrapperSerialization stringFromJSONObject:dataDictionary];
    }
    
    UnitySendMessage("LEGODeviceManager", CStringFromNSString(unityMethodName), CStringFromNSString(dataString));
}

@end
