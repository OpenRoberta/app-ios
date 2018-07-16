//
// Created by Søren Toft Odgaard on 15/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LERevision;

/** Represent the type of an attached IO (motor, sensor, etc). */
typedef NS_ENUM(uint8_t, LEIOType) {

    /** A Motor - use the LEMotor to communicate with this type of IO */
    LEIOTypeMotor = 1,  //0x01

    /** A Voltage Sensor - use the LEVoltageSensor to communicate with this type of IO */
    LEIOTypeVoltage = 20, //0x14

    /** A Current Sensor - use the LECurrentSensor to communicate with this type of IO */
    LEIOTypeCurrent = 21, //0x15

    /** A Piezo Tone player - use the LEPiezoTonePlayer to communicate with this type of IO */
    LEIOTypePiezoTone = 22, //0x16

    /** An RGB light - use the LERGBLight to communicate with this type of IO */
    LEIOTypeRGBLight = 23, //0x17


    /** A Tilt Sensor - use the LETiltSensor to communicate with this type of IO */
    LEIOTypeTiltSensor = 34, //0x22

    /** A Motion Sensor (aka. Detect Sensor) - use the LEMotionSensor to communicate with this type of IO */
    LEIOTypeMotionSensor = 35, //0x23

    /** A type unknown to the SDK - use the LEGenericService to communicate with this type of IO. */
    LEIOTypeGeneric,
};


/**
 The Connect Info represent generic info about an IO (service) attached to a device.
*/
@interface LEConnectInfo : NSObject

/** An identifier used to uniquely identify and address the service. The device is guaranteed not to have two services with the same connectID at the same time */
@property (nonatomic, readonly) uint8_t connectID;

/** The index of the port on the Hub the IO is attached to. If the index is higher than or equal to 50 the service is an internal service */
@property (nonatomic, readonly) uint8_t hubIndex;

/* The raw type number of the IO as received from the Device. Use the typeEnum property to get the type as an LEIOType */
@property (nonatomic, readonly) uint8_t type;

/** The hardware revision of the attached IO as received from the device */
@property (nonatomic, readonly) LERevision *hardwareVersion;

/** The firmware revision of the attached IO as received from the device */
@property (nonatomic, readonly) LERevision *firmwareVersion;

/** The type of the IO as a string - useful for printing in debug statements */
@property (nonatomic, readonly) NSString *typeString;

/** The type of the IO. Use the type property to get the raw type number as it received from the device */
@property (nonatomic, readonly) LEIOType typeEnum;

/**
 Format an LEIOType as a string - useful for printing in debug statements
 @param type    The type to format as a string
*/
+ (NSString *)stringFromInputType:(LEIOType)type;


/** @name Check for equality */

/**
 Return YES if this connect info is equal to info.
 @param info    The connect info to check for equality with
*/
- (BOOL)isEqualToConnectInfo:(LEConnectInfo *)info;

@end