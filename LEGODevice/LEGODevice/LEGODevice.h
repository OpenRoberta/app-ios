//
//  LEGODevice.h
//  LEGODevice
//
//  Created by Jon Nørrelykke on 04/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#ifndef LEGODevice_LEGODevice_h
#define LEGODevice_LEGODevice_h

#include "LEErrorCodes.h"
#include "LELogger.h"

//Device
#include "LEDeviceManager.h"
#include "LEDevice.h"
#include "LEDeviceInfo.h"
#include "LERevision.h"

//Input and Output
#include "LEInputFormat.h"
#include "LEDataFormat.h"

//Services
#include "LEService.h"
#include "LEGenericService.h"
#include "LEMotionSensor.h"
#include "LEMotor.h"
#include "LEPiezoTonePlayer.h"
#include "LERGBLight.h"
#include "LETiltSensor.h"
#include "LEVoltageSensor.h"
#include "LECurrentSensor.h"

#define LE_SDK_VERSION @"2.4.0"

//SDK has been tested to work with the specified version of the bluetooth device firmware
//The SDK will not work with a device with another major version.
#define LE_BLUETOOTH_DEVICE_FIRMWARE_VERSION @"1.0.3.0"

#endif
