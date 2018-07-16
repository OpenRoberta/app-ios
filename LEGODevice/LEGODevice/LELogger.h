//
// Created by Søren Toft Odgaard on 10/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Log level
*/
typedef NS_ENUM(NSUInteger, LELoggerLevel) {
    /** Verbose Level */
    LELoggerLevelVerbose = 0,
    /** Debug Level */
    LELoggerLevelDebug = 1,
    /** Info Level */
    LELoggerLevelInfo = 2,
    /** Warn Level */
    LELoggerLevelWarn = 3,
    /** Error Level */
    LELoggerLevelError = 4,
    /** Fatal Level */
    LELoggerLevelFatal = 5
};

/**
You may provide an implementation of this protocol to the LELogger to have all
log from the LEGO Device SDK written to a custom destination (for instance a remote logging server).
*/
@protocol LELogWriter <NSObject>

/**
Writes a message from the LEGO Device SDK to a custom logging destination.

@param message  The message that will be written to the logging destination
@param level    The log level
*/
- (void)writeMessage:(NSString *)message logLevel:(LELoggerLevel)level;

@end


/**
Use this class to configure the log level that you want the LEGO Device SDK to use.

You may provide your own log-writer that all log from the LEGO Device SDK will be written to,
by setting the logWriter property.
*/
@interface LELogger : NSObject

/** @name Getting an instance of the Logger */

/** @return The shared LELogger */
+ (instancetype)defaultLogger;

/**
The log level. Default is Error.

@discussion For AppStore build you should set the log level to Error or Warn.
The library will not log debug info in AppStore builds.
*/
@property (nonatomic, readwrite) LELoggerLevel logLevel;

/**
Convenience property for checking if the log level is set to debug (or below)
*/
@property (nonatomic, readonly, getter=isDebugLoggingEnabled) BOOL debugLoggingEnabled;

/**
You may set a custom log writer that all log from the library will be written to.
If set to nil (the default) log will be from the library using the standard NSLog
*/
@property (nonatomic, strong) id <LELogWriter> logWriter;

@end