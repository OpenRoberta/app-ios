//
// Created by Søren Toft Odgaard on 07/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEOutputCommand.h"
#import "LEConnectInfo.h"

@interface LEOutputCommandTest : LETestCase

@end


@implementation LEOutputCommandTest {

    LEOutputCommand *_command;

    uint8_t _connectID;
}

- (void)setUp
{
    [super setUp];
    _connectID = 1;
}

- (void)testWriteMotorPowerCommand
{
    int8_t writtenPower = 100;
    _command = [LEOutputCommand commandWriteMotorPower:writtenPower connectID:_connectID];

    NSData *data = _command.data;
    XCTAssertEqual(4, data.length, @"Unexpected length of set speed command");

    Byte *bytes = (Byte *) data.bytes;
    XCTAssertEqual(_connectID, bytes[0]);

    uint8_t expectedCommandID = 1;   //Write motor power commandID
    XCTAssertEqual(expectedCommandID, bytes[1]);

    uint8_t expectedNumberOfBytes = 1;
    XCTAssertEqual(expectedNumberOfBytes, bytes[2]);

    XCTAssertEqual(writtenPower, bytes[3]);
}


- (void)testWriteMotorPowerCommand_NegativeSpeed
{
    int8_t writtenPower = -100;
    _command = [LEOutputCommand commandWriteMotorPower:writtenPower connectID:_connectID];

    Byte *bytes = (Byte *) _command.data.bytes;
    XCTAssertEqual(writtenPower, (int8_t) bytes[3]);
}

- (void)testWritePiezoToneFrequency
{
    uint16_t frequency = 440;
    uint16_t duration = 1000;

    _command = [LEOutputCommand commandWritePiezoToneFrequency:frequency milliseconds:duration connectID:_connectID];


    NSData *data = _command.data;
    XCTAssertEqual(7, data.length, @"Unexpected length of write piezo tone command");


    Byte *bytes = (Byte *) data.bytes;
    XCTAssertEqual(_connectID, bytes[0]);

    uint8_t expectedCommandID = 2;   //Play Piezo Tone commandID
    XCTAssertEqual(expectedCommandID, bytes[1]);

    uint8_t expectedNumberOfBytes = 4; //Two bytes for frequency and two for duration in ms
    XCTAssertEqual(expectedNumberOfBytes, bytes[2]);

    uint16_t writtenFrequency = 0;
    [data getBytes:&writtenFrequency range:NSMakeRange(3, 2)];
    XCTAssertEqual(writtenFrequency, frequency);

    uint16_t writtenDuration = 0;
    [data getBytes:&writtenDuration range:NSMakeRange(5, 2)];
    XCTAssertEqual(writtenDuration, duration);
}


- (void)testWritePiezoToneStop
{
    _command = [LEOutputCommand commandWritePiezoToneStopForConnectID:_connectID];

    NSData *data = _command.data;
    XCTAssertEqual(3, data.length, @"Unexpected length stop piezo tone command");

    Byte *bytes = (Byte *) data.bytes;
    XCTAssertEqual(_connectID, bytes[0]);

    uint8_t expectedCommandID = 3;   //Stop Piezo Tone commandID
    XCTAssertEqual(expectedCommandID, bytes[1]);

    uint8_t expectedNumberOfBytes = 0; //No payload
    XCTAssertEqual(expectedNumberOfBytes, bytes[2]);
}

- (void)testWriteRGB
{
    uint8_t red = 0;
    uint8_t green = 255;
    uint8_t blue = 128;
    _command = [LEOutputCommand commandWriteRGBLightRed:red green:green blue:blue connectId:_connectID];

    NSData *data = _command.data;
    XCTAssertEqual(6, data.length, @"Unexpected length of write RGB command");

    Byte *bytes = (Byte *) data.bytes;
    XCTAssertEqual(_connectID, bytes[0]);

    uint8_t expectedCommandID = 4;   //Write RGB commandID
    XCTAssertEqual(expectedCommandID, bytes[1]);

    uint8_t expectedNumberOfBytes = 3; //One byte for each color component
    XCTAssertEqual(expectedNumberOfBytes, bytes[2]);

    XCTAssertEqual(red, bytes[3]);
    XCTAssertEqual(green, bytes[4]);
    XCTAssertEqual(blue, bytes[5]);
}


@end