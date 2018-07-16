//
// Created by Søren Toft Odgaard on 11/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEBluetoothDevice.h"

static NSString *const LEDeviceInterrogationFinishedNotification = @"LEDeviceStateInterrogationFinished";

@interface LEBluetoothDevice (Project)  <CBPeripheralDelegate>

+ (LEBluetoothDevice *)deviceWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (id)initWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (void)updateWithAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;

- (void)cleanUp;

- (void)deviceDidConnect;

@property (nonatomic, readwrite, getter=isAdvertising) BOOL advertising;

@end