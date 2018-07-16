//
// Created by Søren Toft Odgaard on 14/11/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//


#import <XCTest/XCTest.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "LEBluetoothDevice.h"
#import "LEBluetoothDevice+Project.h"
#import "LETestCase.h"
#import "LEBluetoothServiceDefinition.h"
#import "LEDeviceServiceDefinition.h"
#import "LEBluetoothHelper.h"
#import "LEIOServiceDefinition.h"
#import "NSMutableArray+Test.h"
#import "LEDeviceInfoServiceDefinition.h"
#import "LERevision+Project.h"

@interface LEBluetoothDevice (Test) <LEDeviceDelegate, CBPeripheralDelegate>
@property (nonatomic, readwrite) BOOL interrogationFinished;
@end


@interface LEBluetoothDeviceTest : LETestCase <LEDeviceDelegate>


@end


@implementation LEBluetoothDeviceTest {
    LEBluetoothDevice *_device;
    NSMutableArray *_serviceAddedThroughDelegate;
    CBPeripheral *_peripheral;
    NSString *_notifiedName;
    CBService *_deviceService;
    CBService *_deviceInfoService;
    BOOL _notifiedButtonStatePressed;
    BOOL _notifiedLowVoltageAlert;

    NSData *_someRevisionData;
}


- (void)setUp
{
    [super setUp];
    _serviceAddedThroughDelegate = [NSMutableArray array];

    _peripheral = [CoreBluetoothMockFactory peripheralWithServices];
    _deviceService = [LEBluetoothHelper serviceWithUUID:[LEBluetoothServiceDefinition deviceServiceDefinition].serviceUUID inPeripheral:_peripheral];
    _deviceInfoService = [LEBluetoothHelper serviceWithUUID:[LEBluetoothServiceDefinition deviceInfoServiceDefinition].serviceUUID inPeripheral:_peripheral];
    CBService *ioService = [LEBluetoothHelper serviceWithUUID:[LEBluetoothServiceDefinition ioServiceDefinition].serviceUUID inPeripheral:_peripheral];

    _device = [LEBluetoothDevice deviceWithPeripheral:_peripheral advertisementData:@{ } RSSI:nil];
    [_device addDelegate:self];

    //We need to make sure the DeviceService 'discovers' the device service and all of it characteristics
    [_device peripheral:_peripheral didDiscoverServices:nil];
    [_device peripheral:_peripheral didDiscoverCharacteristicsForService:_deviceService error:nil];
    [_device peripheral:_peripheral didDiscoverCharacteristicsForService:_deviceInfoService error:nil];
    [_device peripheral:_peripheral didDiscoverCharacteristicsForService:ioService error:nil];

    _someRevisionData = [NSData dataFromHexString:@"00 64 FF 01"]; //0, 100, 255, 1
}

- (void)tearDown
{
    [super tearDown];
    [_device removeDelegate:self];
}


- (void)testReceiveUpdatedDeviceName
{
    //Setup
    NSString *deviceName = @"ABCDefgh";
    CBCharacteristic *nameChar = [CoreBluetoothMockFactory deviceNameCharacteristicWithData:[deviceName dataUsingEncoding:NSUTF8StringEncoding] peripheral:_peripheral];

    //Execute method under test (MUT)
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:nameChar error:nil];

    //Verify results
    XCTAssertEqualObjects(deviceName, _device.name);
    XCTAssertEqualObjects(deviceName, _notifiedName);
}

- (void)testWriteDeviceName
{
    NSString *newName = @"STOs Cool Device";

    CBUUID *nameUUID = [LEBluetoothServiceDefinition deviceServiceDefinition].deviceName.UUID;

    //Setting the name requires the state to be connected
    id peripheralMock = _peripheral;
    [[[peripheralMock stub] andReturnValue:@(CBPeripheralStateConnected)] state];


    //Setup expected behaviour
    [CoreBluetoothMockFactory
            expectDataWritten:[newName dataUsingEncoding:NSUTF8StringEncoding]
            type:CBCharacteristicWriteWithResponse
            service:_deviceService
            characteristicUUID:nameUUID];

    //Run method under test
    _device.name = newName;

    //Verify write called on the peripheral
    [CoreBluetoothMockFactory verifyMockPeripheralInService:_deviceService];
}

- (void)testUpdatedAdvertisementData_device_name
{
    //Setup
    NSString *deviceName = @"My Device";

    //Execute MUT
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataLocalNameKey : deviceName } RSSI:@0];

    //Verify
    XCTAssertEqualObjects(deviceName, _device.name);
    XCTAssertEqualObjects(deviceName, _notifiedName);
}

- (void)testUpdateAdvertisementData_button_pressed_and_released
{
    //Setup for pressed
    NSData *buttonPressedData = [NSData dataFromHexString:@"01"];
    NSDictionary *serviceAdvertisementDic = @{
            [LEBluetoothServiceDefinition deviceServiceDefinition].shortServiceUUID :
            buttonPressedData };

    //Execute MUT
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : serviceAdvertisementDic } RSSI:nil];

    XCTAssertTrue(_device.buttonPressed);
    XCTAssertTrue(_notifiedButtonStatePressed);


    //Setup for not pressed
    buttonPressedData = [NSData dataFromHexString:@"00"];
    serviceAdvertisementDic = @{
            [LEBluetoothServiceDefinition deviceServiceDefinition].shortServiceUUID :
            buttonPressedData };

    //Execute MUT
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : serviceAdvertisementDic } RSSI:nil];

    XCTAssertFalse(_device.buttonPressed);
    XCTAssertFalse(_notifiedButtonStatePressed);
}

- (void)testDiscoverPeripheral_advertisement_data_updates_are_aggregated_over_time
{
    // Setup advertised data
    NSDictionary *serviceData = @{};
    NSNumber *txPowerLevel = @42;
    
    // Advertise data in chunks
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : serviceData } RSSI:nil];
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataTxPowerLevelKey : txPowerLevel } RSSI:nil];
    
    // Verify that advertised data has been merged
    XCTAssertEqualObjects(_device.advertisementData[CBAdvertisementDataServiceDataKey], serviceData);
    XCTAssertEqualObjects(_device.advertisementData[CBAdvertisementDataTxPowerLevelKey], txPowerLevel);
}

- (void)testUpdateAdvertisementData_robust_to_empty_service_data_dictionary
{
    //Execute MUT
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:nil];

    XCTAssertFalse(_notifiedButtonStatePressed);
}

- (void)testDidChangeIO_add_io
{
    NSData *hwRevisionData = [NSData dataFromHexString:@"00 64 FF 01"]; //0, 100, 255, 1
    LERevision *hwRevision = [LERevision revisionWithData:hwRevisionData];

    NSData *fwRevisionData = [NSData dataFromHexString:@"01 64 FF 05"];//1, 100, 255, 5
    LERevision *fwRevision = [LERevision revisionWithData:fwRevisionData];

    CBCharacteristic *characteristic = [CoreBluetoothMockFactory deviceTypesAttachedCharacteristicWithData:
            [self dataForAttachedIOWithConnectID:1 hubIndex:2 type:LEIOTypeMotionSensor hardwareVersion:hwRevisionData firmwareVersion:fwRevisionData] peripheral:_peripheral];

    //Execute method under test
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];

    //Verify 
    XCTAssertEqual(1U, _serviceAddedThroughDelegate.count);
    XCTAssertEqual(1U, _device.services.count);

    LEService *firstService = _device.services[0];
    XCTAssertTrue(firstService.connectInfo.type == LEIOTypeMotionSensor);
    XCTAssertEqualObjects(firstService.connectInfo.hardwareVersion, hwRevision);
    XCTAssertEqualObjects(firstService.connectInfo.firmwareVersion, fwRevision);
}

- (void)testDidChangeIO_add_and_remove_io_services
{
    //Add first service
    CBCharacteristic *characteristic = [CoreBluetoothMockFactory deviceTypesAttachedCharacteristicWithData:
            [self dataForAttachedIOWithConnectID:1 hubIndex:2 type:LEIOTypeMotionSensor hardwareVersion:_someRevisionData firmwareVersion:_someRevisionData] peripheral:_peripheral];
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];


    //Add second service
    characteristic = [CoreBluetoothMockFactory deviceTypesAttachedCharacteristicWithData:
            [self dataForAttachedIOWithConnectID:2 hubIndex:0 type:LEIOTypeVoltage hardwareVersion:_someRevisionData firmwareVersion:_someRevisionData] peripheral:_peripheral];
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];

    //Verify
    XCTAssertEqual(2U, _serviceAddedThroughDelegate.count);
    XCTAssertEqual(2U, _device.services.count);

    //Remove first service
    characteristic = [CoreBluetoothMockFactory deviceTypesAttachedCharacteristicWithData:[NSData dataFromHexString:@"01 00"] peripheral:_peripheral]; //O1 = connectId, 00 = detach
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];

    //Verify
    XCTAssertEqual(1U, _serviceAddedThroughDelegate.count);
    XCTAssertEqual(1U, _device.services.count);
}

- (void)testDidChangeIO_cannot_add_same_connectID_twice
{
    //This test is to make sure that the SDK is robust for receiving the same attachedIO package duplicates, and do not add the same service twice.
    CBCharacteristic *characteristic = [CoreBluetoothMockFactory deviceTypesAttachedCharacteristicWithData:
            [self dataForAttachedIOWithConnectID:1 hubIndex:2 type:LEIOTypeMotionSensor hardwareVersion:_someRevisionData firmwareVersion:_someRevisionData] peripheral:_peripheral];

    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];

    //Verify
    XCTAssertEqual(1U, _serviceAddedThroughDelegate.count);
    XCTAssertEqual(1U, _device.services.count);
}


- (NSData *)dataForAttachedIOWithConnectID:(uint8_t)connectID hubIndex:(uint8_t)hubIndex type:(uint8_t)type hardwareVersion:(NSData *)hwVersion firmwareVersion:(NSData *)fwVersion
{
    NSMutableData *data = [NSMutableData new];
    [data appendBytes:&connectID length:1];
    uint8_t attachedByte = 0x01;
    [data appendBytes:&attachedByte length:1];
    [data appendBytes:&hubIndex length:1];
    [data appendBytes:&type length:1];
    [data appendData:hwVersion];
    [data appendData:fwVersion];
    return data;
}


- (void)testDidChangeButtonState
{
    XCTAssertFalse(_device.buttonPressed);

    //Pressed
    NSData *buttonData = [NSData dataFromHexString:@"01"];
    CBCharacteristic *characteristic = [CoreBluetoothMockFactory deviceButtonCharacteristicWithData:buttonData peripheral:_peripheral];
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];
    XCTAssertTrue(_device.buttonPressed);
    XCTAssertTrue(_notifiedButtonStatePressed);

    //Not pressed
    buttonData = [NSData dataFromHexString:@"00"];
    characteristic = [CoreBluetoothMockFactory deviceButtonCharacteristicWithData:buttonData peripheral:_peripheral];
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];
    XCTAssertFalse(_device.buttonPressed);
    XCTAssertFalse(_notifiedButtonStatePressed);
}

- (void)testDidUpdateLowVoltage
{
    XCTAssertFalse(_device.lowVoltage);

    //Alert
    NSData *data = [NSData dataFromHexString:@"01"];
    CBCharacteristic *characteristic = [CoreBluetoothMockFactory deviceLowVoltageAlertCharacteristicWithData:data peripheral:_peripheral];
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];
    XCTAssertTrue(_device.lowVoltage);
    XCTAssertTrue(_notifiedLowVoltageAlert);

    //Not alert
    data = [NSData dataFromHexString:@"00"];
    characteristic = [CoreBluetoothMockFactory deviceLowVoltageAlertCharacteristicWithData:data peripheral:_peripheral];
    [_device peripheral:_peripheral didUpdateValueForCharacteristic:characteristic error:nil];
    XCTAssertFalse(_device.lowVoltage);
    XCTAssertFalse(_notifiedButtonStatePressed);

}


- (void)testDidUpdateRSSIValues
{
    NSNumber *rssiValue = @-10;
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:rssiValue];
    XCTAssertEqualObjects(rssiValue, _device.RSSI);
}

- (void)testDidUpdateRSSIValues_averaging_always_picks_the_middle_value_in_a_sorted_list
{
    NSNumber *nmb = @-1;
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:nmb];
    XCTAssertEqualObjects(nmb, _device.RSSI);

    nmb = @-5;
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:nmb];
    //When picking the middle value in a sorted list of even size, we always round down
    XCTAssertEqualObjects(@-1, _device.RSSI);

    nmb = @-3;
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:nmb];
    XCTAssertEqualObjects(@-3, _device.RSSI);

    nmb = @-4;
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:nmb];
    //four values in the list, the middle one is still -3
    XCTAssertEqualObjects(@-3, _device.RSSI);

    nmb = @-4;
    [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:nmb];
    XCTAssertEqualObjects(@-4, _device.RSSI);

}


//After having received more that only the last 10 values received are taken into account
- (void)testDidUpdateRSSIValues_averaging_only_last_10_values_count
{
    NSUInteger numberOfValuesToAverage = 10;
    NSMutableArray *rssiValues = [NSMutableArray arrayWithCapacity:numberOfValuesToAverage];
    for (int i = 1; i <= numberOfValuesToAverage; ++i) {
        [rssiValues addObject:@(-i * 2)];
    }

    //After this, the array now contains all numbers from -2..-4...-20 in a random order
    [rssiValues shuffle];

    NSNumber *expectedAverage = @-10;

    //Execute method under test
    for (NSNumber *nmb in rssiValues) {
        [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:nmb];
    }

    XCTAssertEqualObjects(expectedAverage, _device.RSSI);


    //Now add the new numbers and make sure only the new number goes into the average
    //as the should have replaced all of the ten previously received numbers
    [rssiValues removeAllObjects];
    for (int i = 1; i <= numberOfValuesToAverage; ++i) {
        [rssiValues addObject:@(-i * 2 - 40)];
    }

    //After this, the array now contains all numbers from -42..-44...-60 in a random order
    [rssiValues shuffle];

    expectedAverage = @-50;
    for (NSNumber *nmb in rssiValues) {
        [_device updateWithAdvertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } } RSSI:nmb];
    }

    XCTAssertEqualObjects(expectedAverage, _device.RSSI);
}


- (void)testEquals
{
    //If two devices refer to holds the same peripheral, they are considered equals
    LEBluetoothDevice *device1 = [LEBluetoothDevice deviceWithPeripheral:_peripheral advertisementData:@{ } RSSI:nil];
    LEBluetoothDevice *device2 = [LEBluetoothDevice deviceWithPeripheral:_peripheral advertisementData:@{ CBAdvertisementDataLocalNameKey : @"A name" } RSSI:nil];
    LEBluetoothDevice *device3 = [LEBluetoothDevice deviceWithPeripheral:[CoreBluetoothMockFactory peripheralWithServices] advertisementData:@{ } RSSI:nil];

    XCTAssertTrue([device1 isEqual:device1]);

    XCTAssertTrue([device1 isEqual:device2]);
    XCTAssertTrue([device2 isEqual:device1]);

    XCTAssertFalse([device1 isEqual:device3]);
    XCTAssertFalse([device3 isEqual:device1]);
}

- (void)testConnectState_disconnected
{
    id peripheralMock = _peripheral;
    [[[peripheralMock stub] andReturnValue:@(CBPeripheralStateDisconnected)] state];

    _device.advertising = NO;
    XCTAssertEqual(LEDeviceStateDisconnectedNotAdvertising, _device.connectState);

}

- (void)testConnectState_disconnected_not_advertising
{
    id peripheralMock = _peripheral;
    [[[peripheralMock stub] andReturnValue:@(CBPeripheralStateDisconnected)] state];

    _device.advertising = YES;
    XCTAssertEqual(LEDeviceStateDisconnectedAdvertising, _device.connectState);
}


- (void)testConnectState_connecting
{
    id peripheralMock = _peripheral;

    CBPeripheralState state = CBPeripheralStateConnecting;
    NSValue *stateValue = [NSValue valueWithBytes:&state objCType:@encode(CBPeripheralState)];
    [[[peripheralMock stub] andReturnValue:stateValue] state];

    XCTAssertEqual(LEDeviceStateConnecting, _device.connectState);
}

- (void)testConnectState_connected_interrogating
{
    id peripheralMock = _peripheral;
    [[[peripheralMock stub] andReturnValue:@(CBPeripheralStateConnected)] state];

    _device.interrogationFinished = NO;
    XCTAssertEqual(LEDeviceStateInterrogating, _device.connectState);
}

- (void)testConnectState_connected_interrogation_finished
{
    id peripheralMock = _peripheral;
    [[[peripheralMock stub] andReturnValue:@(CBPeripheralStateConnected)] state];

    _device.interrogationFinished = YES;
    XCTAssertEqual(LEDeviceStateInterrogationFinished, _device.connectState);
}


#pragma mark - Device Delegate

- (void)device:(LEDevice *)device didAddService:(LEService *)service
{
    [_serviceAddedThroughDelegate addObject:service];
}

- (void)device:(LEDevice *)device didRemoveService:(LEService *)service
{
    [_serviceAddedThroughDelegate removeObject:service];
}

- (void)device:(LEDevice *)device didChangeNameFrom:(NSString *)oldName to:(NSString *)newName
{
    _notifiedName = newName;
}

- (void)device:(LEDevice *)device didChangeButtonState:(BOOL)pushed
{
    _notifiedButtonStatePressed = pushed;
}

- (void)device:(LEDevice *)device didUpdateLowVoltageState:(BOOL)lowVoltage
{
    _notifiedLowVoltageAlert = lowVoltage;
}

- (void)device:(LEDevice *)device didFailToAddServiceWithError:(NSError *)error
{
    XCTFail(@"Failed to add service: %@", error.localizedDescription);
}

@end