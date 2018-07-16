//
//  LEGOLoggerWrapperTest.m
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 01/04/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEGOLoggerUnityWrapper.h"
#import "LEGODevice.h"
#import "LEGODeviceSDK-Native.h"


@interface LEGOLoggerWrapperTest : LETestCase

@property (strong, nonatomic) id loggerMock;

@end


@implementation LEGOLoggerWrapperTest

#pragma mark - Setup

- (void)setUp
{
    [super setUp];
    self.loggerMock = [OCMockObject niceMockForClass:[LELogger class]];
    [[[self.loggerMock stub] andReturn:self.loggerMock] defaultLogger];
}

- (void)tearDown
{
    [self.loggerMock stopMocking];
    [super tearDown];
}

#pragma mark - Tests

#pragma mark API Methods

- (void)testSetLogLevel
{
    // Setup
    int logLevel = 2;
    [[self.loggerMock expect] setLogLevel:logLevel];
    
    // Test
    LEGOLogger_setLogLevel(logLevel);
    
    // Verify
    [self.loggerMock verify];
}

@end
