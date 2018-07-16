//
//  LEBluetoothIOTest.m
//  LEGODevice
//
//  Created by Søren Toft Odgaard on 02/05/14.
//  Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LEBluetoothIO.h"
#import "CoreBluetoothMockFactory.h"
#import "LEInputFormat.h"
#import "LEConnectInfo+Project.h"
#import "LETestStubFactory.h"
#import "OCMockObject.h"
#import "LEOutputCommand.h"
#import "LEBluetoothHelper.h"
#import "LEIOServiceDefinition.h"

@interface LEBluetoothIOTest : XCTestCase <LEIODelegate>

@end

@implementation LEBluetoothIOTest {
    LEBluetoothIO *_bluetoothIO;

    LEConnectInfo *_connectInfo;
    LEConnectInfo *_activeConnectInfo;

    LEInputFormat *_notifiedInputFormat;

    NSData *_notifiedValueData;
}

- (void)setUp
{
    [super setUp];

    _connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:1];
    _activeConnectInfo = _connectInfo;

    _bluetoothIO = [LEBluetoothIO bluetoothIOWithService:[CoreBluetoothMockFactory inputService]];
    [_bluetoothIO addDelegate:self];
}

- (void)tearDown
{
    [super tearDown];
    [_bluetoothIO removeDelegate:self];
}

- (void)testHandleUpdatedInputFormat_SuccessScenario
{
    uint8_t version = 1;
    uint8_t mode = 0;
    uint32_t deltaInterval = 1234;
    uint8_t unit = 1;
    uint8_t notificationsEnabled = 1;
    uint8_t numberOfBytes = 2;
    NSData *formatData = [LETestStubFactory inputFormatWriteDataWithRevision:version connectID:_connectInfo.connectID typeID:_connectInfo.type mode:mode deltaInterval:deltaInterval unit:unit notificationsEnabled:notificationsEnabled numberOfBytes:numberOfBytes];
    CBCharacteristic *inputFormatCharacteristic = [CoreBluetoothMockFactory inputFormatCharacteristicWithData:formatData];

    //Parse the data to the method under test
    [_bluetoothIO handleUpdatedInputServiceCharacteristic:inputFormatCharacteristic];

    //Test that an LEInputFormat is correctly created
    XCTAssertNotNil(_notifiedInputFormat);
    XCTAssertEqual(_connectInfo.connectID, _notifiedInputFormat.connectID);
    XCTAssertEqual(_connectInfo.type, _notifiedInputFormat.typeID);
    XCTAssertEqual(mode, _notifiedInputFormat.mode);
    XCTAssertEqual(deltaInterval, _notifiedInputFormat.deltaInterval);
    XCTAssertEqual(unit, _notifiedInputFormat.unit);
    XCTAssertTrue(_notifiedInputFormat.notificationsEnabled);
    XCTAssertEqual(numberOfBytes, _notifiedInputFormat.numberOfBytes);
}

- (void)testHandleUpdatedValue_SuccessScenario
{
    //First make sure an input format is set up for the connectionID so received values can be parsed
    uint8_t formatRevision = 2;

    uint8_t connectID1 = 1;
    uint8_t connectID2 = 2;

    //We add two InputFormats
    LEConnectInfo *connectInfo1 = [LEConnectInfo connectInfoWithConnectID:connectID1 hubIndex:1 type:1];
    LEConnectInfo *connectInfo2 = [LEConnectInfo connectInfoWithConnectID:connectID2 hubIndex:2 type:2];
    [self simulateReceivingInputFormatForConnectInfo:connectInfo1 revision:formatRevision numberOfBytesInValue:2];
    [self simulateReceivingInputFormatForConnectInfo:connectInfo2 revision:formatRevision numberOfBytesInValue:1];

    //Then set up the Input Value bytes to be received
    uint16_t value1 = 1000;
    uint8_t value2 = 120;

    NSMutableData *valueData = [NSMutableData data];
    [valueData appendBytes:&formatRevision length:1];
    [valueData appendBytes:&connectID1 length:1];
    [valueData appendBytes:&value1 length:sizeof(value1)];
    [valueData appendBytes:&connectID2 length:1];
    [valueData appendBytes:&value2 length:sizeof(value2)];

    //We make sure that the delegate will return the connectInfo1, meaning that the delegate should receive value1
    _activeConnectInfo = connectInfo1;

    //Parse the data to the method under test
    CBCharacteristic *characteristic = [CoreBluetoothMockFactory inputValueCharacteristicWithData:valueData];
    [_bluetoothIO handleUpdatedInputServiceCharacteristic:characteristic];

    //verify the result
    NSData *expectedResult = [NSData dataWithBytes:&value1 length:sizeof(value1)];
    XCTAssertEqualObjects(expectedResult, _notifiedValueData);


    //Now, we repeat the test, only we make the delegate return connectInfo2, meaning that the delegate should receive value2
    _activeConnectInfo = connectInfo2;

    [_bluetoothIO handleUpdatedInputServiceCharacteristic:characteristic];

    //verify the result
    expectedResult = [NSData dataWithBytes:&value2 length:sizeof(value2)];
    XCTAssertEqualObjects(expectedResult, _notifiedValueData);
}

- (void)testHandleUpdatedValue_ignored_if_format_revision_unknown
{
    uint8_t formatRevision = 2;
    [self simulateReceivingInputFormatForConnectInfo:_connectInfo revision:formatRevision numberOfBytesInValue:1];

    uint8_t valueFormatRevision = 3;    //NOTE: Value format is different from format above
    uint8_t connectID = _connectInfo.connectID;
    uint8_t value = 10;
    NSMutableData *valueData = [NSMutableData data];
    [valueData appendBytes:&valueFormatRevision length:1];
    [valueData appendBytes:&connectID length:1];
    [valueData appendBytes:&value length:sizeof(value)];

    //Execute method under test
    CBCharacteristic *characteristic = [CoreBluetoothMockFactory inputValueCharacteristicWithData:valueData];
    [_bluetoothIO handleUpdatedInputServiceCharacteristic:characteristic];

    //Verify that the value is not updated (as the format version in the value data does not match the last received format)
    XCTAssertNil(_notifiedValueData);
}

- (void)testWriteMotorPower_offset_zero_value_zero_is_correctly_translated
{
    int8_t offset = 0;
    int8_t motorPower = 0;
    int8_t expectedPowerWritten = 0;
    [self verifyWritingMotorPower:motorPower withOffset:offset resultsInPowerWritten:expectedPowerWritten];
}

- (void)testWriteMotorPower_offset_zero_value_100_is_correctly_translated
{
    int8_t offset = 0;
    int8_t motorPower = 100;
    int8_t expectedPowerWritten = 100;
    [self verifyWritingMotorPower:motorPower withOffset:offset resultsInPowerWritten:expectedPowerWritten];
}

- (void)testWriteMotorPower_offset_zero_value_minus_100_is_correctly_translated
{
    int8_t offset = 0;
    int8_t motorPower = -100;
    int8_t expectedPowerWritten = -100;
    [self verifyWritingMotorPower:motorPower withOffset:offset resultsInPowerWritten:expectedPowerWritten];
}


- (void)testWriteMotorPower_offset_30_value_zero_is_correctly_translated
{
    int8_t offset = 30;
    int8_t motorPower = 0;
    int8_t expectedPowerWritten = 30;
    [self verifyWritingMotorPower:motorPower withOffset:offset resultsInPowerWritten:expectedPowerWritten];
}

- (void)testWriteMotorPower_offset_30_value_50_is_correctly_translated
{
    int8_t offset = 30;
    int8_t motorPower = 50;
    int8_t expectedPowerWritten = 65;  //The range goes from 30-100. 50% of that places the value in the middle of that range: 65
    [self verifyWritingMotorPower:motorPower withOffset:offset resultsInPowerWritten:expectedPowerWritten];
}

- (void)testWriteMotorPower_offset_30_value_minus_50_is_correctly_translated
{
    int8_t offset = 30;
    int8_t motorPower = -50;
    int8_t expectedPowerWritten = -65;  //The range goes from 30-100. 50% of that places the value in the middle of that range: 65
    [self verifyWritingMotorPower:motorPower withOffset:offset resultsInPowerWritten:expectedPowerWritten];
}

- (void)testWriteMotorPower_offset_30_value_minus_100_is_correctly_translated
{
    int8_t offset = 30;
    int8_t motorPower = -100;
    int8_t expectedPowerWritten = -100;  //The range goes from 30-100. 50% of that places the value in the middle of that range: 65
    [self verifyWritingMotorPower:motorPower withOffset:offset resultsInPowerWritten:expectedPowerWritten];
}



- (void)testWriteMotorPower_offset_30_value_100_is_correctly_translated
{
    int8_t offset = 30;
    int8_t motorPower = 100;
    int8_t expectedPowerWritten = 100;
    [self verifyWritingMotorPower:motorPower withOffset:offset resultsInPowerWritten:expectedPowerWritten];
}


- (void)verifyWritingMotorPower:(int8_t)motorPower withOffset:(int8_t)offset resultsInPowerWritten:(int8_t)expectedPowerWritten
{
    uint8_t connectID = 0;
    CBUUID *uuid = [LEIOServiceDefinition ioServiceDefinition].outputCommand.UUID;

    LEOutputCommand *outputCommand = [LEOutputCommand commandWriteMotorPower:expectedPowerWritten connectID:connectID];
    [CoreBluetoothMockFactory expectDataWritten:outputCommand.data type:CBCharacteristicWriteWithoutResponse service:_bluetoothIO.service characteristicUUID:uuid];

    [_bluetoothIO writeMotorPower:motorPower offset:offset forConnectID:connectID];

    [CoreBluetoothMockFactory verifyMockPeripheralInService:_bluetoothIO.service];
}


- (void)simulateReceivingInputFormatForConnectInfo:(LEConnectInfo *)connectInfo revision:(uint8_t)version numberOfBytesInValue:(uint8_t)numberOfBytes
{
    uint8_t mode = 0;
    uint32_t deltaInterval = 1234;
    uint8_t unit = 1;
    uint8_t notificationsEnabled = 1;
    NSData *formatData = [LETestStubFactory inputFormatWriteDataWithRevision:version connectID:connectInfo.connectID typeID:connectInfo.type mode:mode deltaInterval:deltaInterval unit:unit notificationsEnabled:notificationsEnabled numberOfBytes:numberOfBytes];
    CBCharacteristic *inputFormatCharacteristic = [CoreBluetoothMockFactory inputFormatCharacteristicWithData:formatData];
    [_bluetoothIO handleUpdatedInputServiceCharacteristic:inputFormatCharacteristic];
}




#pragma mark - LEIODelegate

- (void)io:(LEIO *)io didReceiveInputFormat:(LEInputFormat *)inputFormat
{
    _notifiedInputFormat = inputFormat;
}

- (void)io:(LEIO *)io didReceiveValueData:(NSData *)valueData
{
    _notifiedValueData = valueData;
}

- (LEConnectInfo *)ioDidRequestConnectInfo:(LEIO *)io
{
    return _activeConnectInfo;
}


@end
