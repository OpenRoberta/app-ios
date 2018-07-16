//
// Created by Søren Toft Odgaard on 09/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEService.h"
#import "LEService+Project.h"
#import "LEConnectInfo+Project.h"
#import "LEIOStub.h"
#import "LEDataFormat.h"
#import "LETestStubFactory.h"
#import "LEInputFormat+Project.h"
#import "NSData+Test.h"

@interface LEServiceTest : LETestCase
@end


@implementation LEServiceTest {

    LEIOStub *_ioStub;
    LEService *_service;
}

- (void)setUp
{
    [super setUp];
    _ioStub = [[LEIOStub alloc] init];
}

- (void)testValueAsNumbers_raw
{
    _service = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:1] io:_ioStub];

    uint8_t mode = 0;
    LEInputFormatUnit unit = LEInputFormatUnitRaw;
    uint8_t numberOfDataSets = 2;
    uint8_t dataSetSize = 1;

    //Make the service 'receive' a new Input Format from device
    [self updateInputFormatMode:mode unit:unit numberOfBytes:(numberOfDataSets * dataSetSize)];

    //Setup the service to know about the new Input Format (which is required to call the 'numbersFromValueDataSet')
    [_service addValidDataFormat:[LEDataFormat formatWithModeName:@"Count" mode:mode unit:unit sizeOfDataSet:dataSetSize dataSetCount:numberOfDataSets]];
        
    BOOL success = [_service handleUpdatedValueData:[NSData dataFromHexString:@"0102"] error:NULL];
    XCTAssertTrue(success);
    
    NSArray *dataSetNumbers = [_service numbersFromValueDataSet];
    XCTAssertEqual(numberOfDataSets, dataSetNumbers.count);
    XCTAssertEqualObjects(@1, dataSetNumbers[0]);
    XCTAssertEqualObjects(@2, dataSetNumbers[1]);
}

- (void)testValueAsNumbers_SI
{
    _service = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:1] io:_ioStub];

    uint8_t mode = 0;
    LEInputFormatUnit unit = LEInputFormatUnitSI;
    uint8_t numberOfDataSets = 2;
    uint8_t dataSetSize = 4; //Float32 for SI

    //Make the service 'receive' a new Input Format from device
    [self updateInputFormatMode:mode unit:unit numberOfBytes:(numberOfDataSets * dataSetSize)];

    //Setup the service to know about the new Input Format (which is required to call the 'numbersFromValueDataSet')
    [_service addValidDataFormat:[LEDataFormat formatWithModeName:@"Count" mode:mode unit:unit sizeOfDataSet:dataSetSize dataSetCount:numberOfDataSets]];

    Float32 value1 = 12345;
    Float32 value2 = -12345;

    NSError *error;
    BOOL success = [_service handleUpdatedValueData:[NSData dataWithFloat1:value1 float2:value2] error:&error];
    XCTAssertTrue(success, @"Failed: %@", error.localizedDescription);

    NSArray *dataSetNumbers = [_service numbersFromValueDataSet];
    XCTAssertEqual(numberOfDataSets, dataSetNumbers.count);
    XCTAssertEqualObjects(@(value1), dataSetNumbers[0]);
    XCTAssertEqualObjects(@(value2), dataSetNumbers[1]);
}


- (void)updateInputFormatMode:(uint8_t)mode unit:(LEInputFormatUnit)unit numberOfBytes:(uint8_t)numberOfBytes
{
    NSData *data = [LETestStubFactory inputFormatWriteDataWithRevision:1 connectID:_service.connectInfo.connectID
            typeID:_service.connectInfo.type mode:mode deltaInterval:1 unit:unit notificationsEnabled:YES numberOfBytes:numberOfBytes];
    LEInputFormat *format = [LEInputFormat inputFormatWithData:data];
    [_service handleUpdatedInputFormat:format];
}

- (void)testValueAsSignedInt
{
    _service = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:1] io:_ioStub];

    int8_t aSignedInt8 = -127;
    [_service io:_ioStub didReceiveValueData:[NSData dataWithBytes:&aSignedInt8 length:sizeof(aSignedInt8)]];
    XCTAssertEqual((NSInteger) aSignedInt8, _service.valueAsInteger);

    int16_t aSignedInt16 = -12725;
    [_service io:_ioStub didReceiveValueData:[NSData dataWithBytes:&aSignedInt16 length:sizeof(aSignedInt16)]];
    XCTAssertEqual(aSignedInt16, _service.valueAsInteger);

    int32_t aSignedInt32 = -12725456;
    [_service io:_ioStub didReceiveValueData:[NSData dataWithBytes:&aSignedInt32 length:sizeof(aSignedInt32)]];
    XCTAssertEqual(aSignedInt32, _service.valueAsInteger);

}

- (void)testValueAsSignedInt_value_is_zero_if_data_too_big {
    _service = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:1] io:_ioStub];

    int64_t aSignedInt64 = -2552525612345644;
    [_service io:_ioStub didReceiveValueData:[NSData dataWithBytes:&aSignedInt64 length:sizeof(aSignedInt64)]];
    XCTAssertEqual(0, _service.valueAsInteger);
}


- (void)testValueAsFloat
{
    _service = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:1] io:_ioStub];

    Float32 aFloat32 = 12345.12;
    [_service io:_ioStub didReceiveValueData:[NSData dataWithBytes:&aFloat32 length:sizeof(aFloat32)]];
    XCTAssertEqual(aFloat32, _service.valueAsFloat);

    Float32 aNegativeFloat32 = -12345.12;
    [_service io:_ioStub didReceiveValueData:[NSData dataWithBytes:&aNegativeFloat32 length:sizeof(aNegativeFloat32)]];
    XCTAssertEqual(aNegativeFloat32, _service.valueAsFloat);
}

- (void)testValueAsFloat_value_is_zero_if_data_too_big {
    _service = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:1] io:_ioStub];

    Float64 aFloat32 = 123451654564.12;
    [_service io:_ioStub didReceiveValueData:[NSData dataWithBytes:&aFloat32 length:sizeof(aFloat32)]];
    XCTAssertEqual(0, _service.valueAsFloat);
}


- (void)testEquals
{

    LEService *service1 = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:1 hubIndex:2 type:3] io:_ioStub];
    LEService *service2 = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:1 hubIndex:2 type:3] io:_ioStub];
    LEService *service3 = [LEService serviceWithConnectInfo:[LEConnectInfo connectInfoWithConnectID:3 hubIndex:2 type:1] io:_ioStub];

    XCTAssertTrue([service1 isEqualToService:service1]);
    XCTAssertTrue([service1 isEqualToService:service2]);
    XCTAssertTrue([service2 isEqualToService:service1]);

    XCTAssertFalse([service1 isEqualToService:service3]);
    XCTAssertFalse([service3 isEqualToService:service1]);
}


@end