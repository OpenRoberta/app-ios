//
//  LEGOServiceUnityWrapper.m
//  Unity-iPhone
//
//  Created by Kim Jung Nissen on 19/09/14.
//
//

#import "LEGOServiceUnityWrapper.h"
#import "LEGODeviceManagerUnityWrapper.h"
#import "LEGODeviceUnityWrapper.h"
#import "LEGOWrapperUtils.h"
#import "LELogger+Project.h"
#import "LEService+Project.h"
#import "LEGOWrapperSerialization.h"
#import "LEGOUnityInvoker.h"
#import "UnityCallbacks.h"

#if TARGET_OS_IPHONE
    #import <CoreImage/CoreImage.h>
#else
    #import <QuartzCore/QuartzCore.h>
#endif

@implementation LEGOServiceUnityWrapper

+ (instancetype)sharedInstance
{
    static LEGOServiceUnityWrapper *wrapper;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        wrapper = [[LEGOServiceUnityWrapper alloc] init];
    });

    return wrapper;
}

#pragma mark - Wrapper Methods -

#pragma mark LEService

- (void)updateServiceData:(NSString *)leDeviceID forConnectID:(NSString *)connectID
{
    LEService *service = [[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:connectID];
    if (service != nil) {
        [LEGOUnityInvoker invokeMethod:LEServiceUpdateServiceData withData:[LEGOWrapperSerialization serializeServiceWithData:service]];
    }
}

- (void)updateInputFormat:(LEInputFormat *)inputFormat forDevice:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID
{
    if (inputFormat == nil) {
        LEErrorLog(@"Failed to update input format for service %@ on device %@: invalid input format", leDeviceID, leServiceConnectID);
        return;
    }
    
    LEService *service = [[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    [service updateInputFormat:inputFormat];
}

#pragma mark LEMotor

- (void)runMotorForDeviceID:(NSString *)leDeviceID forConnectID:(NSString *)connectID inDirection:(LEMotorDirection)direction power:(NSUInteger)power
{
    LEMotor *motorService = (LEMotor *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:connectID];
    [motorService runInDirection:direction power:power];
}

- (void)brakeMotorForDeviceID:(NSString *)leDeviceID forConnectID:(NSString *)connectID
{
    LEMotor *motorService = (LEMotor *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:connectID];
    [motorService brake];
}

- (void)driftMotorForDeviceID:(NSString *)leDeviceID forConnectID:(NSString *)connectID
{
    LEMotor *motorService = (LEMotor *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:connectID];
    [motorService drift];
}

#pragma mark LERGBLight

- (void)setRGBLightMode:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID rgbLightMode:(NSString *)rgbModeString
{
    LERGBLight *rgbLightService = (LERGBLight *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    LEMotionSensorMode rgbMode = (LEMotionSensorMode)[rgbModeString integerValue];
    rgbLightService.rgbMode = rgbMode;
}

- (void)switchOffRGBLightForDevice:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID
{
    LERGBLight *rgbLightService = (LERGBLight *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    [rgbLightService switchOff];
}

- (void)changeColorOnRGBLightForDevice:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID colorJSON:(NSString *)colorJSON
{
    CIColor *color = [LEGOWrapperSerialization deserializeColor:[LEGOWrapperSerialization objectFromJSONString:colorJSON]];
    if (color == nil) {
        LEErrorLog(@"Invalid color JSON format: %@", colorJSON);
        return;
    }
    
    LERGBLight *rgbLightService = (LERGBLight *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    rgbLightService.color = color;
}

- (void)changeColorIndexOnRGBLightForDevice:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID colorIndex:(NSString *)colorIndex
{
    LERGBLight *rgbLightService = (LERGBLight *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    rgbLightService.colorIndex = (NSUInteger)[colorIndex integerValue];
}

- (void)changeColorToDefaultOnRGBLightForDevice:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID
{
    LERGBLight *rgbLightService = (LERGBLight *) [[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    [rgbLightService switchToDefaultColor];
}

#pragma mark LEMotionSensor

- (void)setMotionSensorMode:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID motionSensorMode:(NSString *)motionSensorModeString
{
    LEMotionSensor *motionSensorService = (LEMotionSensor *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    LEMotionSensorMode motionSensorMode = (LEMotionSensorMode)[motionSensorModeString integerValue];
    motionSensorService.motionSensorMode = motionSensorMode;
}

#pragma mark LETiltSensor

- (void)setTiltSensorMode:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID tiltSensorMode:(NSString *)tiltSensorModeString
{
    LETiltSensor *tiltSensorService = (LETiltSensor *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    LETiltSensorMode tiltSensorMode = (LETiltSensorMode)[tiltSensorModeString integerValue];
    tiltSensorService.tiltSensorMode = tiltSensorMode;
}

#pragma mark LEPiezoTonePlayer

- (void)playFrequencyOnPiezoTonePlayerForDevice:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID frequency:(NSString *)frequency milliseconds:(NSString *)milliseconds
{
    LEPiezoTonePlayer *piezoTonePlayerService = (LEPiezoTonePlayer *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    [piezoTonePlayerService playFrequency:[frequency integerValue] forMilliseconds:[milliseconds integerValue]];
}

- (void)playNoteOnPiezoTonePlayerForDevice:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID note:(NSString *)note octave:(NSString *)octave milliseconds:(NSString *)milliseconds
{
    LEPiezoTonePlayer *piezoTonePlayerService = (LEPiezoTonePlayer *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    LEPiezoTonePlayerNote piezoTonePlayerNote = (LEPiezoTonePlayerNote)[note integerValue];
    [piezoTonePlayerService playNote:piezoTonePlayerNote octave:[octave integerValue] forMilliSeconds:[milliseconds integerValue]];
}

- (void)stopPlayingPiezoTonePlayerForDevice:(NSString *)leDeviceID forConnectID:(NSString *)leServiceConnectID
{
    LEPiezoTonePlayer *piezoTonePlayerService = (LEPiezoTonePlayer *)[[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    [piezoTonePlayerService stopPlaying];
}

#pragma mark - Delegates -

#pragma mark LEServiceDelegate

- (void)service:(LEService *)service didUpdateInputFormatFrom:(LEInputFormat *)oldFormat to:(LEInputFormat *)newFormat
{
    [LEGOUnityInvoker invokeMethod:LEServiceDidUpdateInputFormat withData:[LEGOWrapperSerialization serializeService:service inputFormatChangeFrom:oldFormat to:newFormat]];
}

// TODO [bhy]: this method broadcasts the value data update event even if there's
// no valid data format defined (e.g. for voltage/current sensors, motor, RGB light, etc);
// as a result the OldValue and NewValues fields are empty, or rather equal to zero.
- (void)service:(LEService *)service didUpdateValueDataFrom:(NSData *)oldValue to:(NSData *)newValue
{
    [LEGOUnityInvoker invokeMethod:LEServiceDidUpdateValueData withData:[LEGOWrapperSerialization serializeService:service valueDataChangeFrom:oldValue to:newValue]];
}

#pragma mark LECurrentSensorDelegate

- (void)currentSensor:(LECurrentSensor *)sensor didUpdateMilliAmp:(CGFloat)milliAmp
{
    [LEGOUnityInvoker invokeMethod:LECurrentSensorDidUpdateMilliAmp withData:[LEGOWrapperSerialization serializeCurrentSensor:sensor currentChangeTo:milliAmp]];
}

#pragma mark LEMotionSensorDelegate

- (void)motionSensor:(LEMotionSensor *)sensor didUpdateCountTo:(NSUInteger)count
{
    [LEGOUnityInvoker invokeMethod:LEMotionSensorDidUpdateCount withData:[LEGOWrapperSerialization serializeMotionSensor:sensor countChangeTo:count]];
}

- (void)motionSensor:(LEMotionSensor *)sensor didUpdateDistanceFrom:(CGFloat)oldDistance to:(CGFloat)newDistance
{
    [LEGOUnityInvoker invokeMethod:LEMotionSensorDidUpdateDistance withData:[LEGOWrapperSerialization serializeMotionSensor:sensor distanceChangeFrom:oldDistance to:newDistance]];
}

#pragma mark LERGBLightDelegate

- (void)rgbLight:(LERGBLight *)rgbLight didUpdateColorFrom:(CIColor *)oldColor to:(CIColor *)newColor
{
    [LEGOUnityInvoker invokeMethod:LERGBLightDidUpdateColor withData:[LEGOWrapperSerialization serializeRGBLight:rgbLight colorChangeFrom:oldColor to:newColor]];
}

- (void)rgbLight:(LERGBLight *)rgbLight didUpdateColorIndexFrom:(NSUInteger)oldColorIndex to:(NSUInteger)newColorIndex
{
    [LEGOUnityInvoker invokeMethod:LERGBLightDidUpdateColorIndex withData:[LEGOWrapperSerialization serializeRGBLightIndex:rgbLight colorChangeFromIndex:oldColorIndex to:newColorIndex]];
}

#pragma mark LETiltSensorDelegate

- (void)tiltSensor:(LETiltSensor *)sensor didUpdateAngleFrom:(LETiltSensorAngle)oldAngle to:(LETiltSensorAngle)newAngle
{
    [LEGOUnityInvoker invokeMethod:LETiltSensorDidUpdateAngle withData:[LEGOWrapperSerialization serializeTiltSensor:sensor angleChangeFrom:oldAngle to:newAngle]];
}

- (void)tiltSensor:(LETiltSensor *)sensor didUpdateCrashFrom:(LETiltSensorCrash)oldCrashValue to:(LETiltSensorCrash)newCrashValue
{
    [LEGOUnityInvoker invokeMethod:LETiltSensorDidUpdateCrash withData:[LEGOWrapperSerialization serializeTiltSensor:sensor crashChangeFrom:oldCrashValue to:newCrashValue]];
}

- (void)tiltSensor:(LETiltSensor *)sensor didUpdateDirectionFrom:(LETiltSensorDirection)oldDirection to:(LETiltSensorDirection)newDirection
{
    [LEGOUnityInvoker invokeMethod:LETiltSensorDidUpdateDirection withData:[LEGOWrapperSerialization serializeTiltSensor:sensor directionChangeFrom:oldDirection to:newDirection]];
}

#pragma mark LEVoltageSensorDelegate

- (void)voltageSensor:(LEVoltageSensor *)sensor didUpdateMilliVolts:(CGFloat)milliVolts
{
    [LEGOUnityInvoker invokeMethod:LEVoltageSensorDidUpdateMilliVolts withData:[LEGOWrapperSerialization serializeVoltageSensor:sensor voltageChangeTo:milliVolts]];
}

@end

#pragma mark - Wrapper Functions Exposed to Unity

#pragma mark LEService

void LEGOService_updateServiceData(const char *legoDeviceID, const char *connectID)
{
    [[LEGOServiceUnityWrapper sharedInstance] updateServiceData:NSStringFromCString(legoDeviceID)
                                                   forConnectID:NSStringFromCString(connectID)];
}

void LEGOService_updateInputFormat(const char *legoDeviceID, const char *connectID, const char *mode, const char *unit, const char *deltaInterval, BOOL notificationEnabled)
{
    NSString *leDeviceID = NSStringFromCString(legoDeviceID);
    NSString *leServiceConnectID = NSStringFromCString(connectID);
    
    LEService *service = [[LEGODeviceManagerUnityWrapper sharedInstance] serviceWithDeviceID:leDeviceID connectID:leServiceConnectID];
    LEInputFormat *inputFormat = [LEInputFormat inputFormatWithConnectID:service.connectInfo.connectID
                                                                  typeID:service.connectInfo.type
                                                                    mode:(uint8_t)NSIntegerFromCString(mode)
                                                           deltaInterval:(uint32_t)NSIntegerFromCString(deltaInterval)
                                                                    unit:(LEInputFormatUnit)NSIntegerFromCString(unit)
                                                    notificationsEnabled:notificationEnabled];
    [[LEGOServiceUnityWrapper sharedInstance] updateInputFormat:inputFormat forDevice:leDeviceID forConnectID:leServiceConnectID];
}

#pragma mark LEMotor

void LEGOService_run(const char *legoDeviceID, const char *connectID, const char *motorDirection, const char *power)
{
    [[LEGOServiceUnityWrapper sharedInstance] runMotorForDeviceID:NSStringFromCString(legoDeviceID)
                                                     forConnectID:NSStringFromCString(connectID)
                                                      inDirection:(LEMotorDirection)NSIntegerFromCString(motorDirection)
                                                            power:(NSUInteger)NSIntegerFromCString(power)];
}

void LEGOService_brake(const char *legoDeviceID, const char *connectID)
{
    [[LEGOServiceUnityWrapper sharedInstance] brakeMotorForDeviceID:NSStringFromCString(legoDeviceID)
                                                       forConnectID:NSStringFromCString(connectID)];
}

void LEGOService_drift(const char *legoDeviceID, const char *connectID)
{
    [[LEGOServiceUnityWrapper sharedInstance] driftMotorForDeviceID:NSStringFromCString(legoDeviceID)
                                                       forConnectID:NSStringFromCString(connectID)];
}

#pragma mark LERGBLight

void LEGOService_setRGBLightMode(const char *legoDeviceID, const char *connectID, const char *rgbLightMode)
{
    [[LEGOServiceUnityWrapper sharedInstance] setRGBLightMode:NSStringFromCString(legoDeviceID)
                                                     forConnectID:NSStringFromCString(connectID)
                                                 rgbLightMode:NSStringFromCString(rgbLightMode)];
}

void LEGOService_switchOff(const char *legoDeviceID, const char *connectID)
{
    [[LEGOServiceUnityWrapper sharedInstance] switchOffRGBLightForDevice:NSStringFromCString(legoDeviceID)
                                                            forConnectID:NSStringFromCString(connectID)];
}

void LEGOService_changeColorToDefault(const char *legoDeviceID, const char *connectID)
{
    [[LEGOServiceUnityWrapper sharedInstance] changeColorToDefaultOnRGBLightForDevice:NSStringFromCString(legoDeviceID)
                                                                         forConnectID:NSStringFromCString(connectID)];
}

void LEGOService_changeColor(const char *legoDeviceID, const char *connectID, const char *jsonColor)
{
    [[LEGOServiceUnityWrapper sharedInstance] changeColorOnRGBLightForDevice:NSStringFromCString(legoDeviceID)
                                                                forConnectID:NSStringFromCString(connectID)
                                                                   colorJSON:NSStringFromCString(jsonColor)];
}

void LEGOService_changeColorIndex(const char *legoDeviceID, const char *connectID, const char *colorIndex)
{
    [[LEGOServiceUnityWrapper sharedInstance] changeColorIndexOnRGBLightForDevice:NSStringFromCString(legoDeviceID)
                                                                forConnectID:NSStringFromCString(connectID)
                                                                   colorIndex:NSStringFromCString(colorIndex)];
}

#pragma mark LEMotionSensor

void LEGOService_setMotionSensorMode(const char *legoDeviceID, const char *connectID, const char *motionSensorMode)
{
    [[LEGOServiceUnityWrapper sharedInstance] setMotionSensorMode:NSStringFromCString(legoDeviceID)
                                                     forConnectID:NSStringFromCString(connectID)
                                                 motionSensorMode:NSStringFromCString(motionSensorMode)];
}

#pragma mark LETiltSensor

void LEGOService_setTiltSensorMode(const char *legoDeviceID, const char *connectID, const char *tiltSensorMode)
{
    [[LEGOServiceUnityWrapper sharedInstance] setTiltSensorMode:NSStringFromCString(legoDeviceID)
                                                   forConnectID:NSStringFromCString(connectID)
                                                 tiltSensorMode:NSStringFromCString(tiltSensorMode)];
}

#pragma mark LEPiezoTonePlayer

void LEGOService_playFrequency(const char *legoDeviceID, const char *connectID, const char *frequency, const char *milliseconds)
{
    [[LEGOServiceUnityWrapper sharedInstance] playFrequencyOnPiezoTonePlayerForDevice:NSStringFromCString(legoDeviceID)
                                                                         forConnectID:NSStringFromCString(connectID)
                                                                            frequency:NSStringFromCString(frequency)
                                                                         milliseconds:NSStringFromCString(milliseconds)];
}

void LEGOService_playNote(const char *legoDeviceID, const char *connectID, const char *note, const char *octave, const char *milliseconds)
{
    [[LEGOServiceUnityWrapper sharedInstance] playNoteOnPiezoTonePlayerForDevice:NSStringFromCString(legoDeviceID)
                                                                    forConnectID:NSStringFromCString(connectID)
                                                                            note:NSStringFromCString(note)
                                                                          octave:NSStringFromCString(octave)
                                                                    milliseconds:NSStringFromCString(milliseconds)];
}

void LEGOService_stopPlaying(const char *legoDeviceID, const char *connectID)
{
    [[LEGOServiceUnityWrapper sharedInstance] stopPlayingPiezoTonePlayerForDevice:NSStringFromCString(legoDeviceID)
                                                                     forConnectID:NSStringFromCString(connectID)];
}
