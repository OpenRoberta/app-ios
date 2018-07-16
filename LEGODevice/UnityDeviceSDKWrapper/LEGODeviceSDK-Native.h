//
//  LEGODeviceSDK-Native.h
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 13/04/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#ifndef LEGODevice_Native_h
#define LEGODevice_Native_h

// ====================
// LEGODeviceManager
// ====================
void LEGODeviceManager_scan();
void LEGODeviceManager_stopScanning();
void LEGODeviceManager_connectToDevice(const char *legoDeviceID);
void LEGODeviceManager_disconnectDevice(const char *legoDeviceID);
const char * LEGODeviceManager_allDevices();

// ====================
// LEGODevice
// ====================
void LEGODevice_updateDeviceName(const char *legoDeviceID, const char *name);

// ====================
// LEGOService
// ====================
void LEGOService_updateServiceData(const char *legoDeviceID, const char *connectID);
void LEGOService_updateInputFormat(const char *legoDeviceID, const char *connectID, const char *mode, const char *unit, const char *deltaInterval, BOOL notificationEnabled);

// Motor
void LEGOService_run(const char *legoDeviceID, const char *connectID, const char *motorDirection, const char *power);
void LEGOService_brake(const char *legoDeviceID, const char *connectID);
void LEGOService_drift(const char *legoDeviceID, const char *connectID);

// RGB light
void LEGOService_setRGBLightMode(const char *legoDeviceID, const char *connectID, const char *rgbLightMode);
void LEGOService_switchOff(const char *legoDeviceID, const char *connectID);
void LEGOService_changeColorToDefault(const char *legoDeviceID, const char *connectID);
void LEGOService_changeColor(const char *legoDeviceID, const char *connectID, const char *jsonColor);
void LEGOService_changeColorIndex(const char *legoDeviceID, const char *connectID, const char *colorIndex);

// Motion sensor
void LEGOService_setMotionSensorMode(const char *legoDeviceID, const char *connectID, const char *motionSensorMode);

// Tilt sensor
void LEGOService_setTiltSensorMode(const char *legoDeviceID, const char *connectID, const char *tiltSensorMode);

// Piezo tone player
void LEGOService_playFrequency(const char *legoDeviceID, const char *connectID, const char *frequency, const char *milliseconds);
void LEGOService_playNote(const char *legoDeviceID, const char *connectID, const char *note, const char *octave, const char *milliseconds);
void LEGOService_stopPlaying(const char *legoDeviceID, const char *connectID);

// ====================
// LEGOLogger
// ====================
//LELoggerLevelVerbose = 0,
//LELoggerLevelDebug = 1,
//LELoggerLevelInfo = 2,
//LELoggerLevelWarn = 3,
//LELoggerLevelError = 4,
//LELoggerLevelFatal = 5
void LEGOLogger_setLogLevel(int level);

#endif
