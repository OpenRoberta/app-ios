//
//  LEGOServiceUnityWrapper.h
//  Unity-iPhone
//
//  Created by Kim Jung Nissen on 19/09/14.
//
//

#import <LEGODevice/LEGODevice.h>

@interface LEGOServiceUnityWrapper : NSObject <LECurrentSensorDelegate, LEMotionSensorDelegate, LERGBLightDelegate, LEServiceDelegate, LETiltSensorDelegate, LEVoltageSensorDelegate>

+ (instancetype)sharedInstance;

@end
