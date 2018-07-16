//
//  LEMotorDelegate.m
//  LEGODevice
//
//  Created by Jon Nørrelykke on 19/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LETestCase.h"
#import "LEMotor.h"
#import "LEIOStub.h"
#import "LEService+Project.h"
#import "LEConnectInfo+Project.h"


@interface LEMotorTest : LETestCase
@end


@implementation LEMotorTest {

    LEMotor *_motor;
    LEIOStub *_ioStub;
}


- (void)setUp
{
    [super setUp];
    _ioStub = [LEIOStub new];
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:LEIOTypeMotor];
    _motor = [[LEMotor alloc] initWithConnectInfo:connectInfo io:_ioStub];
}


- (void)testRunMotorRight
{

    [_motor runInDirection:LEMotorDirectionRight power:100];
    XCTAssertEqual(100, _motor.power);
    XCTAssertEqual(100, _ioStub.lastWrittenMotorPower);
    XCTAssertEqual(LEMotorDirectionRight, _motor.direction);
    XCTAssertFalse(_motor.isBraking);
    XCTAssertFalse(_motor.isDrifting);

    [_motor runInDirection:LEMotorDirectionRight power:1];
    XCTAssertEqual(1, _motor.power);
    XCTAssertEqual(1, _ioStub.lastWrittenMotorPower);
    XCTAssertEqual(LEMotorDirectionRight, _motor.direction);
    XCTAssertFalse(_motor.isBraking);
    XCTAssertFalse(_motor.isDrifting);

    [_motor runInDirection:LEMotorDirectionRight power:0];
    XCTAssertEqual(0, _motor.power);
    XCTAssertEqual(0, _ioStub.lastWrittenMotorPower);
    XCTAssertEqual(LEMotorDirectionDrifting, _motor.direction);
    XCTAssertTrue(_motor.isDrifting);
    XCTAssertFalse(_motor.isBraking);
}

- (void)testRunMotorLeft
{
    [_motor runInDirection:LEMotorDirectionLeft power:100];
    XCTAssertEqual(100, _motor.power);
    XCTAssertEqual(-100, _ioStub.lastWrittenMotorPower);
    XCTAssertEqual(LEMotorDirectionLeft, _motor.direction);
    XCTAssertFalse(_motor.isBraking);
    XCTAssertFalse(_motor.isDrifting);

    [_motor runInDirection:LEMotorDirectionLeft power:1];
    XCTAssertEqual(1, _motor.power);
    XCTAssertEqual(-1, _ioStub.lastWrittenMotorPower);
    XCTAssertEqual(LEMotorDirectionLeft, _motor.direction);
    XCTAssertFalse(_motor.isBraking);
    XCTAssertFalse(_motor.isDrifting);

    [_motor runInDirection:LEMotorDirectionLeft power:0];
    XCTAssertEqual(0, _motor.power);
    XCTAssertTrue(_motor.isDrifting);
    XCTAssertEqual(0, _ioStub.lastWrittenMotorPower);
    XCTAssertEqual(LEMotorDirectionDrifting, _motor.direction);
    XCTAssertTrue(_motor.isDrifting);
    XCTAssertFalse(_motor.isBraking);

}


- (void)testMotorDrift
{
    [_motor drift];
    XCTAssertEqual(0, _motor.power);
    XCTAssertEqual(0, _ioStub.lastWrittenMotorPower);
    XCTAssertEqual(LEMotorDirectionDrifting, _motor.direction);
    XCTAssertTrue(_motor.isDrifting);
    XCTAssertFalse(_motor.isBraking);

}

- (void)testMotorBrake {
    [_motor brake];
    XCTAssertEqual(0, _motor.power);
    XCTAssertEqual(127, _ioStub.lastWrittenMotorPower);
    XCTAssertEqual(LEMotorDirectionBraking, _motor.direction);
    XCTAssertFalse(_motor.isDrifting);
    XCTAssertTrue(_motor.isBraking);
}


@end