//
//  UnityIOSBridge.m
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 09/03/15.
//  Copyright (c) 2015 LEGO. All rights reserved.
//

// Define a stub for the Unity callback function when compiling non-wrapper iOS targets.
// Otherwise the build is going to fail in the linking phase.
void UnitySendMessage(const char* obj, const char* method, const char* msg)
{
    NSLog(@"Unity send message: %s %s %s", obj, method, msg);
}
