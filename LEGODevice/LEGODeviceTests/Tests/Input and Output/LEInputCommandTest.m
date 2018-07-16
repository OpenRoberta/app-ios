//
// Created by Søren Toft Odgaard on 02/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEInputCommand.h"
#import "LEInputFormat.h"
#import "LEConnectInfo+Project.h"

static const int CommandIDInputValue = 0;
static const int CommandIDInputFormat = 1;

static const int CommandTypeRead = 1;
static const int CommandTypeWrite = 2;

@interface LEInputCommandTest : LETestCase

@end


@implementation LEInputCommandTest {

}

- (void)setUp
{
    [super setUp];
}

- (void)testWriteInputFormat
{
    //Setup the format to write
    LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:2 type:3];
    LEInputFormat *format = [LEInputFormat inputFormatWithConnectID:connectInfo.connectID typeID:connectInfo.type mode:9 deltaInterval:10 unit:LEInputFormatUnitRaw notificationsEnabled:YES];


    //Set up the expected byte-stream in the write command
    uint8_t typeID = connectInfo.type;
    uint8_t mode = format.mode;
    uint32_t deltaInterval = format.deltaInterval;
    LEInputFormatUnit unit = LEInputFormatUnitRaw;
    uint8_t notificationEnabled = 1;

    NSMutableData *expectedDataWritten = [NSMutableData data];
    [self appendCommandHeaderToData:expectedDataWritten commandID:CommandIDInputFormat commandType:CommandTypeWrite connectID:connectInfo.connectID];
    [expectedDataWritten appendBytes:&(typeID) length:sizeof(typeID)];
    [expectedDataWritten appendBytes:&mode length:sizeof(mode)];
    [expectedDataWritten appendBytes:&deltaInterval length:sizeof(deltaInterval)];
    [expectedDataWritten appendBytes:&unit length:sizeof(unit)];
    [expectedDataWritten appendBytes:&notificationEnabled length:sizeof(notificationEnabled)];

    //Execute the method under test (MUT)
    LEInputCommand *command = [LEInputCommand commandWriteInputFormat:format connectID:connectInfo.connectID];

    //Verify the command data byte stream
    XCTAssertEqualObjects(expectedDataWritten, command.data);
}


- (void)testReadInputValues
{
    //Setup expected result
    NSMutableData *expectedDataWritten = [NSMutableData data];
    [self appendCommandHeaderToData:expectedDataWritten commandID:CommandIDInputValue commandType:CommandTypeRead connectID:2];

    //Execute the MUT
    LEInputCommand *command = [LEInputCommand commandReadValueForConnectID:2];

    //Verify
    XCTAssertEqualObjects(expectedDataWritten, command.data);
}


- (void)appendCommandHeaderToData:(NSMutableData *)data commandID:(uint8_t)commandID commandType:(uint8_t)commandType connectID:(uint8_t)connectID
{
    [data appendBytes:&commandID length:sizeof(commandID)];
    [data appendBytes:&commandType length:sizeof(commandType)];
    [data appendBytes:&connectID length:sizeof(connectID)];
}


@end