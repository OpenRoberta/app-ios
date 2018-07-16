//
// Created by Søren Toft Odgaard on 26/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEInputFormat.h"

/**
This class contains info detailing how the data received for a given service (typically a sensor of some kind) should be interpreted.

For senors types recognized by the SDK (like the tilt and motion sensor) you will not need to know about
the details of this class as the implementation of these services in the SDK handles this for you.

If you need to access an Input that is not recognized by the SDK you should create and set one
or more valid input formats for a LEService. See the LEGenericService documentation for an example.
*/
@interface LEDataFormat : NSObject

/** @name Creating and initializing a data format */

/**
Create and initialize a new instance of an LEDataFormat.

Example: When a tilt sensor is in mode 'angle' it will create readings of in the x, y and z-dimension. If the mode is set to SI each
angle will be a float representing with a value between 0 and 90 degrees. To create a data set that tells the SDK how to interpret values
for til tilt sensor in this mode you would write.

    LEDataFormat *tiltSensorFormat = [LEDataFormat formatWithModeName:@"Angle" mode:0 unit:LEInputFormatUnitSI sizeOfDataSet:3 dataSetCount:4];


@param modeName         The name of the mode
@param modeValue        The sensor mode
@param unit             The sensor unit
@param numberOfBytes    The number of bytes in a data set
@param numberOfDataSets The number of data sets
*/
+ (instancetype)formatWithModeName:(NSString *)modeName mode:(uint8_t)modeValue unit:(LEInputFormatUnit)unit sizeOfDataSet:(uint8_t)numberOfBytes dataSetCount:(uint8_t)numberOfDataSets;

/** @name Other properties */

/** The name sensor mode (fx. crash, tilt or angle for a tilt sensor) */
@property (nonatomic, readonly) NSString *modeName;

/** The sensor mode */
@property (nonatomic, readonly) uint8_t mode;

/** The sensor unit name (Raw or SI) */
@property (nonatomic, readonly) NSString *unitName;

/** The sensor unit */
@property (nonatomic, readonly) LEInputFormatUnit unit;

/** The data set size - fx. 4 if the data is a four byte float */
@property (nonatomic, readonly) uint8_t dataSetSize;

/** The data set count (fx. size 3 for a sensor that produce a value in x, y and z-direction) */
@property (nonatomic, readonly) uint8_t dataSetCount;


/** @name Check for equality */

/**
 Returns YES if this data format is equal to otherFormat
 @param otherFormat     The format to be compared to the receiver.
*/
- (BOOL)isEqualToFormat:(LEDataFormat *)otherFormat;


@end