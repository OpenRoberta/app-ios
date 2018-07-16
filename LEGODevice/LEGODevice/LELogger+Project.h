//
// Created by Søren Toft Odgaard on 10/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LELogger.h"

#define LEVerboseLog(fmt, ...) LELog(LELoggerLevelVerbose, (@"Verbose: LEGO Device: " fmt), ##__VA_ARGS__)
#define LEDebugLog(fmt, ...) LELog(LELoggerLevelDebug, (@"DEBUG: LEGO Device: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define LEInfoLog(fmt, ...) LELog(LELoggerLevelInfo, (@"INFO: LEGO Device: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define LEWarnLog(fmt, ...) LELog(LELoggerLevelWarn, (@"WARN: LEGO Device: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define LEErrorLog(fmt, ...) LELog(LELoggerLevelError, (@"ERROR: LEGO Device: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define LEFatalLog(fmt, ...) LELog(LELoggerLevelFatal, (@"FATAL: LEGO Device: %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@interface LELogger (Project)

- (void)log:(NSString *)format args:(va_list)args level:(LELoggerLevel)level;

@end

extern void LELog(LELoggerLevel level, NSString *format, ...);
