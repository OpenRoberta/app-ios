//
// Created by Søren Toft Odgaard on 10/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LELogger.h"


@implementation LELogger

+ (instancetype)defaultLogger
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.logLevel = LELoggerLevelError;
    }
    return self;
}

- (void)setLogLevel:(LELoggerLevel)logLevel
{
    if (self.isReleaseBuild && logLevel < LELoggerLevelWarn) {
        NSLog(@"Maximum log level supported for release builds is Warning");
        _logLevel = LELoggerLevelWarn;
    } else {
        _logLevel = logLevel;
    }
}

- (BOOL)isReleaseBuild
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_MAC
    return NO;
#else
    // The embedded.mobileprovision file doesn't exist in apps distributed through the App Store
    NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    return provisionPath==nil;
#endif
}



@end