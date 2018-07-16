//
//  LETest.m
//  LEGODevice
//
//  Created by Søren Toft Odgaard on 18/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LELogger.h"

@implementation LETestCase

- (void)setUp
{
    [super setUp];
    [LELogger defaultLogger].logLevel = LELoggerLevelDebug;
}

- (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];

    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if ([timeoutDate timeIntervalSinceNow] < 0.0) {
            break;
        }
    }
    while (!*flag);
    return *flag;
}



@end
