//
//  LEBluetoothDeviceManagerTest.m
//  LEGODeviceDemo
//
//  Created by Søren Toft Odgaard on 15/05/14.
//  Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LEBluetoothDeviceManager.h"
#import "LETestCase.h"

@interface LEBluetoothDeviceManager (Test) <CBCentralManagerDelegate>
@end


@interface LEBluetoothDeviceManagerTest : LETestCase <LEBluetoothDeviceManagerDelegate>

@end

@implementation LEBluetoothDeviceManagerTest {

    id _centralManagerNiceMock;
    LEBluetoothDeviceManager *_manager;
    CBPeripheral *_peripheral;

    NSMutableArray *_devicesAddedThroughDelegate;
    BOOL _deviceDidDisapperDelegateInvoked;
}

- (void)setUp
{
    [super setUp];
    _devicesAddedThroughDelegate = [NSMutableArray new];
    _centralManagerNiceMock = [OCMockObject niceMockForClass:[CBCentralManager class]];
    _manager = [[LEBluetoothDeviceManager alloc] initWithCentralManager:_centralManagerNiceMock];
    _manager.delegate = self;
    _peripheral = [CoreBluetoothMockFactory peripheralWithServices];

}


- (void)testDeviceDidAppear_two_different_peripherals_adds_two_new_devices
{
    CBPeripheral *peripheral1 = [CoreBluetoothMockFactory peripheralWithServices];
    CBPeripheral *peripheral2 = [CoreBluetoothMockFactory peripheralWithServices];

    [_manager centralManager:_centralManagerNiceMock
            didDiscoverPeripheral:peripheral1
            advertisementData:@{ CBAdvertisementDataLocalNameKey : @"My Device 1" }
            RSSI:@-50];

    [_manager centralManager:_centralManagerNiceMock
            didDiscoverPeripheral:peripheral2
            advertisementData:@{ CBAdvertisementDataLocalNameKey : @"My Device 2" }
            RSSI:@-50];


    XCTAssertEqual(2, [_manager devicesInState:LEDeviceStateDisconnectedAdvertising].count);
    XCTAssertEqual(2, [_manager devicesInState:LEDeviceStateDisconnectedAdvertising].count);
}

- (void)testDeviceDidAppear_two_identical_peripherals_adds_only_one_device
{
    [_manager centralManager:_centralManagerNiceMock
            didDiscoverPeripheral:_peripheral
            advertisementData:@{ CBAdvertisementDataLocalNameKey : @"My Device 1" }
            RSSI:@-50];

    [_manager centralManager:_centralManagerNiceMock
            didDiscoverPeripheral:_peripheral
            advertisementData:@{ CBAdvertisementDataLocalNameKey : @"My Device 2" }
            RSSI:@-50];

    XCTAssertEqual(1, [_manager devicesInState:LEDeviceStateDisconnectedAdvertising].count);
    XCTAssertEqual(1, [_manager devicesInState:LEDeviceStateDisconnectedAdvertising].count);
}

- (void)testDeviceDidAppear_device_appears_only_when_its_name_is_already_known
{
    // First advertise service data only without a device name
    [_manager centralManager:_centralManagerNiceMock
       didDiscoverPeripheral:_peripheral
           advertisementData:@{ CBAdvertisementDataServiceDataKey : @{ } }
                        RSSI:@-50];
    NSUInteger numberOfDevicesBeforeReceivingName = _manager.allDevices.count;
    
    // Then advertise the device name
    [_manager centralManager:_centralManagerNiceMock
       didDiscoverPeripheral:_peripheral
           advertisementData:@{ CBAdvertisementDataLocalNameKey : @"My Device 1" }
                        RSSI:@-50];
    NSUInteger numberOfDevicesAfterReceivingName = _manager.allDevices.count;
    
    // Verify
    XCTAssertEqual(0, numberOfDevicesBeforeReceivingName);
    XCTAssertEqual(1, numberOfDevicesAfterReceivingName);
}

- (void)testDeviceDidDisappear
{
    //Seconds to wait before removing a device that has not been seen advertising
    NSTimeInterval secondsToWait = 1.0;
    [_manager setUpdateAdvertisingDevicesInterval:secondsToWait];

    //We need to call scan, as this starts the timer that will remove devices
    //that has not been seen advertising for some time
    [_manager scan];

    //Make the Central Manger disocver a new device
    [_manager centralManager:_centralManagerNiceMock
            didDiscoverPeripheral:_peripheral
            advertisementData:@{ CBAdvertisementDataLocalNameKey : @"My Device 1" }
            RSSI:@-50];
    XCTAssertEqual(1, [_manager devicesInState:LEDeviceStateDisconnectedAdvertising].count);

    //Now, if the device is not seen advertising again within 'secondsToWait' is should
    //cause a 'deviceDidDisappear' notification
    BOOL success = [self waitFor:&_deviceDidDisapperDelegateInvoked timeout:secondsToWait + 3.0];
    XCTAssertTrue(success, @"Timed out waiting for device to be removed from list of advertising devices");

    XCTAssertEqual(0, [_manager devicesInState:LEDeviceStateDisconnectedAdvertising].count,
                    @"Device has not been removed from list of discovered devices");

}

#pragma mark - LEBluetoothDeviceManagerDelegate

- (void)deviceManager:(LEBluetoothDeviceManager *)manager deviceDidAppear:(LEBluetoothDevice *)device
{
    [_devicesAddedThroughDelegate addObject:device];
}

- (void)deviceManager:(LEBluetoothDeviceManager *)manager deviceDidDisappear:(LEBluetoothDevice *)device
{
    [_devicesAddedThroughDelegate removeObject:device];
    _deviceDidDisapperDelegateInvoked = YES;
}

@end
