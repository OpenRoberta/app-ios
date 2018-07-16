//
//  LEGOLoggerUnityWrapper.m
//  LEGODevice
//
//  Created by Søren Toft Odgaard on 18/03/15.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import "LEGOLoggerUnityWrapper.h"
#import "LELogger+Project.h"

@implementation LEGOLoggerUnityWrapper

@end

void LEGOLogger_setLogLevel(int level)
{
    [[LELogger defaultLogger] setLogLevel:level];
}
