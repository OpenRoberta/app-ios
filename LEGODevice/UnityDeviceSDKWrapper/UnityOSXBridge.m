//
//  UnityOSXBridge.m
//  UnityDeviceSDKWrapper
//
//  Created by Bartlomiej Hyzy on 18/02/2015.
//  Copyright (c) 2015 LEGO. All rights reserved.
//

#import "UnityOSXBridge.h"

static LEGOUnityMessageCallback LEGO_messageCallbackOSX = NULL;

void LEGODeviceSDK_setOSXUnityMessageCallback(LEGOUnityMessageCallback callback)
{
    LEGO_messageCallbackOSX = callback;
}

void LEGODeviceSDK_OSX_SendMessageToUnity(const char *objectName, const char *commandName, const char *commandData)
{
    if (LEGO_messageCallbackOSX != NULL) {
        LEGO_messageCallbackOSX(objectName, commandName, commandData);
    }
}
