//
//  LETest.h
//  LEGODevice
//
//  Created by Søren Toft Odgaard on 18/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "OCMockObject.h"
#import "OCMockRecorder.h"
#import "OCMArg.h"

#import "CoreBluetoothMockFactory.h"
#import "NSData+Hex.h"

@interface LETestCase : XCTestCase

- (BOOL)waitFor:(BOOL *)flag timeout:(NSTimeInterval)timeoutSecs;
@end
