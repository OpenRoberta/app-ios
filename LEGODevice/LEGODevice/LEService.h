//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEConnectInfo.h"

@class LEInputFormat;
@class LEService;
@class LEDevice;
@class LEMultiDelegate;
@class LEDataFormat;

/**
 Implement this protocol to be notified when a service (typically a sensor of some kind) sends an updated value.
*/
@protocol LEServiceDelegate <NSObject>

@optional

/**
 Invoked when a service receives an updated value.
 You can use of the convenience methods [LEService numberFromValueData], [LEService valueAsInteger] or [LEService valueAsFloat]
 to retrieve the value as a number.
 @param service     The service that received an updated value
 @param oldValue    The previous value
 @param newValue    The new value
*/
- (void)service:(LEService *)service didUpdateValueDataFrom:(NSData *)oldValue to:(NSData *)newValue;

/**
 Invoked when a service receives an updated LEInputFormat
 @param service    The service that received an updated value
 @param oldFormat  The previous input format
 @param newFormat  The new input format
*/
- (void)service:(LEService *)service didUpdateInputFormatFrom:(LEInputFormat *)oldFormat to:(LEInputFormat *)newFormat;

@end

/**
  An LEService represent an IO of some kind, for example a motor or sensor. It could also be an internal IO, such as Voltage sensor build into the device.

  The LEService has a number of sub-classes for known IO types. This includes LEMotor, LETiltSensor and LEMotionSensor just to mention a few.

  Add a instance of a LEServiceDelegate using addDelegate: to be notified when a service receives an updated value.
*/
@interface LEService : NSObject

/** @name General Service Info */

/** General info about the connected service */
@property (nonatomic, readonly) LEConnectInfo *connectInfo;

/** The Device this service is related to */
@property (nonatomic, weak, readonly) LEDevice *device;

/** Is YES if this service represents an internal IO, such as an LEVoltageSensor */
@property (nonatomic, readonly) BOOL isInternalService;

/** The name of the service */
@property (nonatomic, readonly) NSString *serviceName;


#pragma mark - Input and Data Formats
/** @name Configure the IO mode */

/**
  The default input format that will be uploaded to the device for this service upon discovery of the service.
  Only the known service types (LEMotor, LETiltSensor, etc.) has a default input format.
 */
@property (nonatomic, readonly) LEInputFormat *defaultInputFormat;

/**
 The current input format for this service.
*/
@property (nonatomic, readonly) LEInputFormat *inputFormat;

/**
 Convenience method that will return the mode of the current inputFormat.
 If no inputFormat is set, it will return the mode of the defaultInputFormat.
 If no inputFormat or defaultInputFormat is set, it will return mode 0.
*/
@property (nonatomic, readonly) uint8_t inputFormatMode;

/**
 Send an updated input format for this service to the device.
 If successful this will trigger an invocation of the delegate callback method [LEServiceDelegate service:didUpdateInputFormatFrom:to].
 @param newFormat   The input format to send to the device.
*/
- (void)updateInputFormat:(LEInputFormat *)newFormat;

/**
 Send and updated input format with newMode for this service to the device.
 If no current inputFormat is set, the message will be based on the defaultInputFormat of this service.
 If no defaultInputFormat is set, the call to this method is ignored.
 @param newMode The input new service mode
*/
- (void)updateCurrentInputFormatWithNewMode:(uint8_t)newMode;


/** @name Configure and read valid data formats */
/**
 The data formats that this service may use to parse received data.

 When a new value for a service is received from the device, the SDK
 will look for a LEDataFormat among the validDataFormats that matches the
 [LEInputFormat unit] and [LEInputFormat mode]. If a match is found the LEDataFormat
 is used to parse the received data correctly (as a float, integer).

 The known service types such as LETiltSensor and LEMotionSensor etc. comes with a set
 of predefined validDataFormat and you do not need to add valid data formats yourself.
 However, if you wish to use the LEService with a service type unknown to the SDK
 you must add the valid data formats using the addValidDataFormat: method.
*/
@property (nonatomic, readonly) NSSet *validDataFormats;


/**
 Add a new valid data format.
 @param dataFormat  The data format to add.
 @see validDataFormats
*/
- (void)addValidDataFormat:(LEDataFormat *)dataFormat;

/**
 Remove a valid data format
 @param dataFormat  The data format to remove.
 @see validDataFormats
*/
- (void)removeValidDataFormat:(LEDataFormat *)dataFormat;


#pragma mark - Input Value
/** @name Read IO Input Value */

/** The latest received value from the service as raw data */
@property (nonatomic, readonly) NSData *valueData;


#pragma mark - Format received data as numbers
/*
 The latest received value from the service as an NSNumber.
 If the inputFormat specifies a data set with more than one element, the first element is returned.
 If no valid data format is found to parse the data nil is returned, see validDataFormats.
*/
@property (nonatomic, readonly) NSNumber *numberFromValueData;

/*
 The latest received value from the service as an array of NSNumbers.
 This makes sense if the data set count of the inputFormat is higher than 1. For example, if the data set
 count is two the valueData consists of two numbers.
 If no valid data format is found to parse the data nil is returned, see validDataFormats.
*/
@property (nonatomic, readonly) NSArray *numbersFromValueDataSet;

/**
 The latest received value from the service as an integer.
 If no valid data format is found to parse the data zero is returned, see validDataFormats.
*/
@property (nonatomic, readonly) int32_t valueAsInteger;

/**
 The latest received value from the service as an integer.
 If no valid data format is found to parse the data zero is returned, see validDataFormats.
*/
@property (nonatomic, readonly) Float32 valueAsFloat;

/**
 If the notifications is disabled for the service in the inputFormat through [LEInputFormat notificationsEnabled]
 you will have to use this method to request an updated value for the service.
 The updated value will be delivered through the delegate method [LEServiceDelegate service:didUpdateValueDataFrom:to:].
*/
- (void)sendReadValueRequest;

/** @name Reset IO state */
/**
 This will send a reset command to the Device for this service. Some services has state,
 such as a bump-count for a tilt sensor that you may wish to reset.
*/
- (void)sendResetStateRequest;

/*
 The value representation of data from the service as an NSNumber.
 If the inputFormat specifies a data set with more than one element, the first element is returned.
 If no valid data format is found to parse the data nil is returned, see validDataFormats.
 @param valueData    The data to parse.
 */
- (NSNumber *) numberFromValueData:(NSData *)valueData;

/*
 The value data representation from the service as an array of NSNumbers.
 This makes sense if the data set count of the inputFormat is higher than 1. For example, if the data set
 count is two the valueData consists of two numbers.
 If no valid data format is found to parse the data nil is returned, see validDataFormats.
 @param valueData    The data to parse.
 */
- (NSArray *) numbersFromValueDataSet:(NSData *)valueData;

#pragma mark - Output
/** @name Write data  */
/**
 Will send data to the IO backed by this service. Useful to write data to an output unknown to the SDK.
 @param data    The data to write.
*/
- (void)writeData:(NSData *)data;

#pragma mark - Delegates
/** @name Add and remove delegates */
/**
 Add a delegate to receive service updates.
 @param delegate    The delegate to add
*/
- (void)addDelegate:(id <LEServiceDelegate>)delegate;

/**
 Remove a delegate
 @param delegate    The delegate to remove
*/
- (void)removeDelegate:(id <LEServiceDelegate>)delegate;


#pragma mark - Equals and Hash
/** @name Check for equality */
/**
 Returns YES if this service is equal to otherService - two services are considered equal if their connectInfo are equal
 @param otherService    The service to be compared to the receiver.
*/
- (BOOL)isEqualToService:(LEService *)otherService;

@end