//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEServiceFactory.h"
#import "LEService.h"
#import "LEBluetoothIO.h"
#import "LEGenericService.h"
#import "LEMotionSensor.h"
#import "LEIO.h"
#import "LEConnectInfo.h"
#import "LETiltSensor.h"
#import "LECurrentSensor.h"
#import "LEBluetoothDevice.h"
#import "LEDevice.h"
#import "LEVoltageSensor.h"
#import "LEMotor.h"
#import "LELogger+Project.h"
#import "LEService+Project.h"
#import "LEPiezoTonePlayer.h"
#import "LERGBLight.h"
#import "LEBluetoothDevice.h"


@implementation LEServiceFactory {

}

+ (LEService *)serviceWithConnectInfo:(LEConnectInfo *)connectInfo io:(LEIO *)io device:(LEDevice *)device
{
    if (io == nil || connectInfo == nil) {
        LEErrorLog(@"Cannot instantiate service with nil LEIO object or ConnectInfo");
        return nil;
    }
    LEService *result = nil;
    switch (connectInfo.typeEnum) {
        case LEIOTypeGeneric:
            result = [LEGenericService serviceWithConnectInfo:connectInfo io:io];
            break;
        case LEIOTypeMotionSensor:
            result = [LEMotionSensor serviceWithConnectInfo:connectInfo io:io];
            break;
        case LEIOTypeTiltSensor:
            result = [LETiltSensor serviceWithConnectInfo:connectInfo io:io];
            break;
        case LEIOTypePiezoTone:
            result = [LEPiezoTonePlayer serviceWithConnectInfo:connectInfo io:io];
            break;
        case LEIOTypeMotor:
            result = [LEMotor serviceWithConnectInfo:connectInfo io:io];
            break;
        case LEIOTypeCurrent:
            result = [LECurrentSensor serviceWithConnectInfo:connectInfo io:io];
            break;
        case LEIOTypeVoltage:
            result = [LEVoltageSensor serviceWithConnectInfo:connectInfo io:io];
            break;
        case LEIOTypeRGBLight:
            result = [LERGBLight serviceWithConnectInfo:connectInfo io:io];
            break;
        default:
            result = [LEGenericService serviceWithConnectInfo:connectInfo io:io];
            break;
    }
    result.device = device;
    return result;
}

@end