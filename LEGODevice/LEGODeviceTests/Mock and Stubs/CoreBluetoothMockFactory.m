//
// Created by Søren Toft Odgaard on 29/10/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//


#import <CoreBluetooth/CoreBluetooth.h>
#import "CoreBluetoothMockFactory.h"
#import "OCMockObject.h"
#import "OCMockRecorder.h"
#import "LEBluetoothIO.h"
#import "LEBluetoothServiceDefinition.h"
#import "LEIOServiceDefinition.h"
#import "LEDeviceServiceDefinition.h"
#import "LEBluetoothDevice.h"
#import "LEBluetoothHelper.h"
#import "LEDeviceInfoServiceDefinition.h"

@implementation CoreBluetoothMockFactory {
}


#pragma mark - Services and Peripheral
+ (CBPeripheral *)peripheralWithServices
{
    id mock = [OCMockObject niceMockForClass:[CBPeripheral class]];
    NSArray *services = @[
            [CoreBluetoothMockFactory deviceInfoServiceWithPeripheral:mock],
            [CoreBluetoothMockFactory inputServiceWithPeripheral:mock],
            [CoreBluetoothMockFactory deviceServiceWithPeripheral:mock] ];
    [[[mock stub] andReturn:services] services];
    [[[mock stub] andReturn:@"MockedPeripheral"] name];
    [[[mock stub] andReturn:[NSUUID UUID]] identifier];

    return mock;
}


+ (CBService *)deviceServiceWithPeripheral:(CBPeripheral *)peripheral
{
    CBCharacteristic *nameCharacteristic = [CoreBluetoothMockFactory characteristicWithData:nil characteristicDefinition:[LEBluetoothServiceDefinition deviceServiceDefinition].deviceName];
    CBCharacteristic *ioCharacteristic = [CoreBluetoothMockFactory characteristicWithData:nil characteristicDefinition:[LEBluetoothServiceDefinition deviceServiceDefinition].attachedIO];
    CBCharacteristic *buttonStateCharacteristic = [CoreBluetoothMockFactory characteristicWithData:nil characteristicDefinition:[LEBluetoothServiceDefinition deviceServiceDefinition].deviceButton];

    id mock = [OCMockObject niceMockForClass:[CBService class]];
    [[[mock stub] andReturn:@[ nameCharacteristic, ioCharacteristic, buttonStateCharacteristic ]] characteristics];

    [[[mock stub] andReturn:[LEBluetoothServiceDefinition deviceServiceDefinition].serviceUUID] UUID];

    [[[mock stub] andReturn:peripheral] peripheral];

    return mock;
}

+ (CBService *)deviceInfoServiceWithPeripheral:(CBPeripheral *)peripheral
{
    CBCharacteristic *firmwareRevision = [CoreBluetoothMockFactory characteristicWithData:nil characteristicDefinition:[LEBluetoothServiceDefinition deviceInfoServiceDefinition].firmwareRevision];
    CBCharacteristic *hardwareRevision = [CoreBluetoothMockFactory characteristicWithData:nil characteristicDefinition:[LEBluetoothServiceDefinition deviceInfoServiceDefinition].hardwareRevision];
    CBCharacteristic *softwareRevision = [CoreBluetoothMockFactory characteristicWithData:nil characteristicDefinition:[LEBluetoothServiceDefinition deviceInfoServiceDefinition].softwareRevision];
    CBCharacteristic *manufacturerName = [CoreBluetoothMockFactory characteristicWithData:nil characteristicDefinition:[LEBluetoothServiceDefinition deviceInfoServiceDefinition].manufacturerName];

    id mock = [OCMockObject niceMockForClass:[CBService class]];
    [[[mock stub] andReturn:@[ firmwareRevision, hardwareRevision, softwareRevision, manufacturerName ]] characteristics];

    [[[mock stub] andReturn:[LEBluetoothServiceDefinition deviceInfoServiceDefinition].serviceUUID] UUID];

    [[[mock stub] andReturn:peripheral] peripheral];

    return mock;
}


+ (CBService *)inputService
{
    return [self inputServiceWithPeripheral:[OCMockObject niceMockForClass:[CBPeripheral class]]];
}


+ (CBService *)inputServiceWithPeripheral:(CBPeripheral *)peripheral
{
    CBCharacteristic *valueCharacteristic = [CoreBluetoothMockFactory inputValueCharacteristicWithData:nil];
    CBCharacteristic *formatCharacteristic = [CoreBluetoothMockFactory inputFormatCharacteristicWithData:nil];
    CBCharacteristic *inputCommandCharacteristic = [CoreBluetoothMockFactory inputCommandCharacteristicWithData:nil];
    CBCharacteristic *outputCommandCharacteristic = [CoreBluetoothMockFactory outputCommandCharacteristicWithData:nil];

    id mock = [OCMockObject niceMockForClass:[CBService class]];
    [[[mock stub] andReturn:@[ valueCharacteristic, formatCharacteristic, inputCommandCharacteristic, outputCommandCharacteristic]] characteristics];


    [[[mock stub] andReturn:[[LEBluetoothServiceDefinition ioServiceDefinition] serviceUUID]] UUID];

    [[[mock stub] andReturn:peripheral] peripheral];

    return mock;
}


#pragma mark -  IO Service Characteristics
+ (CBCharacteristic *)inputValueCharacteristicWithData:(NSData *)valueData
{
    return [self characteristicWithData:valueData
            characteristicDefinition:[LEBluetoothServiceDefinition ioServiceDefinition].inputValue];
}

+ (CBCharacteristic *)inputFormatCharacteristicWithData:(NSData *)valueData
{
    return [self characteristicWithData:valueData
            characteristicDefinition:[LEBluetoothServiceDefinition ioServiceDefinition].inputFormat];
}

+ (CBCharacteristic *)inputCommandCharacteristicWithData:(NSData *)valueData
{
    return [self characteristicWithData:valueData
            characteristicDefinition:[LEBluetoothServiceDefinition ioServiceDefinition].inputCommand];
}

+ (CBCharacteristic *)outputCommandCharacteristicWithData:(NSData *)valueData
{
    return [self characteristicWithData:valueData
            characteristicDefinition:[LEBluetoothServiceDefinition ioServiceDefinition].outputCommand];
}

#pragma mark - Device Service Characteristics
+ (CBCharacteristic *)deviceNameCharacteristicWithData:(NSData *)data peripheral:(CBPeripheral *)peripheral
{
    id characteristicMock = [self characteristicWithData:data
            characteristicDefinition:[LEBluetoothServiceDefinition deviceServiceDefinition].deviceName];

    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[LEBluetoothServiceDefinition deviceServiceDefinition].serviceUUID]) {
            [[[characteristicMock stub] andReturn:service] service];
        }
    }
    return characteristicMock;
}

+ (CBCharacteristic *)deviceTypesAttachedCharacteristicWithData:(NSData *)data peripheral:(CBPeripheral *)peripheral
{
    return [self
            characteristicWithData:data
            characteristicDefinition:[LEBluetoothServiceDefinition deviceServiceDefinition].attachedIO
            peripheral:peripheral
    ];
}

+ (CBCharacteristic *)deviceButtonCharacteristicWithData:(NSData *)data peripheral:(CBPeripheral *)peripheral
{
    return [self
            characteristicWithData:data
            characteristicDefinition:[LEBluetoothServiceDefinition deviceServiceDefinition].deviceButton
            peripheral:peripheral
    ];
}

+ (CBCharacteristic *)deviceLowVoltageAlertCharacteristicWithData:(NSData *)data peripheral:(CBPeripheral *)peripheral
{
    return [self
            characteristicWithData:data
            characteristicDefinition:[LEBluetoothServiceDefinition deviceServiceDefinition].lowVoltageAlert
            peripheral:peripheral
    ];
}


#pragma mark - General Characteristics (Helpers)
+ (CBCharacteristic *)characteristicWithData:(NSData *)data
                    characteristicDefinition:(LECharacteristicDefinition *)characteristicDefinition
{
    return [self characteristicWithData:data characteristicDefinition:characteristicDefinition peripheral:nil];
}


+ (CBCharacteristic *)characteristicWithData:(NSData *)data
                    characteristicDefinition:(LECharacteristicDefinition *)characteristicDefinition
                                  peripheral:(CBPeripheral *)peripheral
{

    id characteristicMock = [self
            characteristicWithUUID:characteristicDefinition.UUID
            valueData:data
            properties:(characteristicDefinition.mandatoryProperties | characteristicDefinition.recommendedProperties)];

    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:characteristicDefinition.serviceDefinition.serviceUUID]) {
            [[[characteristicMock stub] andReturn:service] service];
        }
    }

    return characteristicMock;
}


+ (id)characteristicWithUUID:(CBUUID *)characteristicUUID valueData:(NSData *)value
{
    return [self characteristicWithUUID:characteristicUUID valueData:value properties:CBCharacteristicPropertyRead];
}

+ (id)characteristicWithUUID:(CBUUID *)characteristicUUID valueData:(NSData *)value properties:(CBCharacteristicProperties)properties
{
    id mock = [OCMockObject niceMockForClass:[CBCharacteristic class]];

    [[[mock stub] andReturn:characteristicUUID] UUID];
    [((CBCharacteristic *)[[mock stub] andReturn:value]) value];

    NSValue *propertiesValue = [NSValue valueWithBytes:&properties objCType:@encode(NSUInteger)];
    [(CBCharacteristic *) [[mock stub] andReturnValue:propertiesValue] properties];

    return mock;
}



#pragma mark - Helpers for setting mock invocation expectations
+ (void)expectDataWritten:(NSData *)data
                     type:(CBCharacteristicWriteType)type
                  service:(CBService *)service
       characteristicUUID:(CBUUID *)characteristicUUID
{
    CBCharacteristic *characteristic = [LEBluetoothHelper characteristicWithUUID:characteristicUUID inService:service];
    assert(characteristic);

    id peripheralMock = service.peripheral;
    [[peripheralMock expect] writeValue:data forCharacteristic:characteristic type:type];
}
//

+ (void)verifyMockPeripheralInService:(CBService *)service
{
    id peripheralMock = service.peripheral;
    [peripheralMock verify];
}


@end