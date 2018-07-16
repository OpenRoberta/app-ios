//
// Created by Søren Toft Odgaard on 07/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LETestCase.h"
#import "LEConnectInfo+Project.h"
#import "LEServiceFactory.h"
#import "LEBluetoothDevice.h"
#import "LEIOStub.h"
#import "LEMotionSensor.h"
#import "LECurrentSensor.h"
#import "LEVoltageSensor.h"
#import "LEGenericService.h"
#import "LEMotor.h"
#import "LEPiezoTonePlayer.h"
#import "LERGBLight.h"

static const uint8_t kTypeTiltSensor = 34;
static const uint8_t kTypeMotionSensor = 35;
static const uint8_t kTypeCurrentSensor = 21;
static const uint8_t kTypeVoltageSensor = 20;

static const uint8_t kTypePiezoTone = 22;
static const uint8_t kTypeMotor = 1;
static const uint8_t kTypeRGBLight = 23;


static const uint8_t kSomeUnknownType1 = 0;
static const uint8_t kSomeUnknownType2 = 99;


@interface LEServiceFactoryTest : LETestCase
@end

@implementation LEServiceFactoryTest {

    LEIO *_dummyIO;
}

- (void)setUp
{
    [super setUp];
    _dummyIO = [[LEIOStub alloc] init];

}


- (void)testCreateServices
{
    //Mapping with the expected "type to class"
    NSDictionary *mappings = @{
            @(kTypeTiltSensor) : [LETiltSensor class],
            @(kTypeMotionSensor) : [LEMotionSensor class],
            @(kTypeCurrentSensor) : [LECurrentSensor class],
            @(kTypeVoltageSensor) : [LEVoltageSensor class],
            @(kTypeMotor) : [LEMotor class],
            @(kTypePiezoTone) : [LEPiezoTonePlayer class],
            @(kTypeRGBLight) : [LERGBLight class],
            @(kSomeUnknownType1) : [LEGenericService class],
            @(kSomeUnknownType2) : [LEGenericService class]
    };

    //Now, verify that the correct type of service is created for each type
    for (NSNumber *typeNumber in mappings) {
        uint8_t type = (uint8_t) typeNumber.unsignedIntegerValue;
        Class expectedClass = mappings[typeNumber];

        LEDevice *deviceMock = [OCMockObject niceMockForClass:[LEDevice class]];
        LEConnectInfo *connectInfo = [self connectInfoWithType:type];
        LEService *service = [LEServiceFactory serviceWithConnectInfo:connectInfo io:_dummyIO device:deviceMock];

        XCTAssertTrue([service isKindOfClass:expectedClass], @"Type %@ resulted in service with class %@, exptected class %@", typeNumber, [service class], expectedClass);
        XCTAssertEqual(service.device, deviceMock);
    }
}


- (LEConnectInfo *)connectInfoWithType:(uint8_t)type
{
    return [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:type];
}


@end
