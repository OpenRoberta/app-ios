//
//  UnityOSXBridge.h
//  UnityDeviceSDKWrapper
//
//  Created by Bartlomiej Hyzy on 18/02/2015.
//  Copyright (c) 2015 LEGO. All rights reserved.
//

// When developing a native OS X plugin for Unity there is no built-in way of communicating with the Unity app from the plugin itself.
// In order to mimic the UnitySendMessage() function available for native iOS plugins, a separate callback mechanism is implemented.

typedef void (*LEGOUnityMessageCallback)(const char *objectName, const char *commandName, const char *commandData);
void LEGODeviceSDK_setOSXUnityMessageCallback(LEGOUnityMessageCallback callback);

void LEGODeviceSDK_OSX_SendMessageToUnity(const char *objectName, const char *commandName, const char *commandData);
