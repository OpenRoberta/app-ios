//
// Created by Søren Toft Odgaard on 9/6/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreBluetooth/CoreBluetooth.h>
#import "LEBluetoothHelper.h"
#import "LELogger+Project.h"
#import "LECharacteristicDefinition.h"
#import "LEIOServiceDefinition.h"
#import "LEInputFormat.h"
#import "LEInputCommand.h"
#import "LEBluetoothIO.h"
#import "LEInputFormat+Project.h"
#import "LEOutputCommand.h"
#import "CBCharacteristic+LEAdditional.h"

@interface LEBluetoothIO ()

@property (nonatomic, strong) CBCharacteristic *inputValueCharacteristic;
@property (nonatomic, strong) CBCharacteristic *inputFormatCharacteristic;
@property (nonatomic, strong) CBCharacteristic *inputCommandCharacteristic;
@property (nonatomic, strong) CBCharacteristic *outputCommandCharacteristic;

@property (nonatomic, strong) LEIOServiceDefinition *serviceDefinition;
@property (nonatomic, strong) NSMutableDictionary *inputFormats;

@end

@implementation LEBluetoothIO


#pragma mark - Create a new LEBluetoothInput

- (id)initWithService:(CBService *)service
{
    if (self = [super init]) {
        assert(service);
        _service = service;

        self.serviceDefinition = [LEIOServiceDefinition ioServiceDefinition];

        self.inputValueCharacteristic = [LEBluetoothHelper characteristicWithUUID:self.serviceDefinition.inputValue.UUID inService:self.service];
        self.inputFormatCharacteristic = [LEBluetoothHelper characteristicWithUUID:self.serviceDefinition.inputFormat.UUID inService:self.service];
        self.inputCommandCharacteristic = [LEBluetoothHelper characteristicWithUUID:self.serviceDefinition.inputCommand.UUID inService:self.service];
        self.outputCommandCharacteristic = [LEBluetoothHelper characteristicWithUUID:self.serviceDefinition.outputCommand.UUID inService:self.service];

        if (!self.inputValueCharacteristic || !self.inputFormatCharacteristic || !self.inputCommandCharacteristic || !self.outputCommandCharacteristic) {
            LEErrorLog(@"IOService missing mandatory characteristic");
            return nil;
        }

        self.inputFormats = [NSMutableDictionary dictionary];

        _delegates = [LEMultiDelegate multiDelegate];

        [service.peripheral setNotifyValue:YES forCharacteristic:self.inputValueCharacteristic];
        [service.peripheral setNotifyValue:YES forCharacteristic:self.inputFormatCharacteristic];
    }
    return self;
}

+ (LEBluetoothIO *)bluetoothIOWithService:(CBService *)service
{
    return [[LEBluetoothIO alloc] initWithService:service];
}


#pragma mark - Access Inputs (e.g. sensors)

- (void)readValueForConnectID:(uint8_t)connectID
{
    [self writeInputCommand:[LEInputCommand commandReadValueForConnectID:connectID]];
}


- (void)resetStateForConnectID:(uint8_t)connectID
{
    //Byte sequence sent to sensor to reset any state (for instance, crash-count for tilt sensor)
    static uint8_t resetBytes[] = { 0x44, 0x11, 0xAA };
    [self writeData:[NSData dataWithBytes:&resetBytes length:3] connectID:connectID];
}

- (void)writeInputFormat:(LEInputFormat *)inputFormat forConnectID:(uint8_t)connectID
{
    [self writeInputCommand:[LEInputCommand commandWriteInputFormat:inputFormat connectID:connectID]];
}

- (void)readInputFormatForConnectID:(uint8_t)connectID
{
    [self writeInputCommand:[LEInputCommand commandReadInputFormatForConnectID:connectID]];
}

- (void)writeInputCommand:(LEInputCommand *)command
{
    LEVerboseLog(@"Writing Input Command: %@", command.data.description);
    [self.service.peripheral writeValue:command.data forCharacteristic:self.inputCommandCharacteristic type:CBCharacteristicWriteWithoutResponse];
}


#pragma mark - Access Outputs (e.g. motors)

- (void)writeMotorPower:(int8_t)power forConnectID:(uint8_t)connectID
{
    [self writeMotorPower:power offset:0 forConnectID:connectID];
}

- (void)writeMotorPower:(int8_t)power offset:(int8_t)offset forConnectID:(uint8_t)connectID
{
    BOOL isPositive = power >= 0;
    power = abs(power);
    
    float actualPower  =  ((100.f - offset) / 100.f) * power + offset;
    int8_t actualResultInt = (int8_t) roundf(actualPower);

    if (!isPositive) {
        actualResultInt = -actualResultInt;
    }
    
    LEOutputCommand *outputCommand = [LEOutputCommand commandWriteMotorPower:actualResultInt  connectID:connectID];
    [self writeOutputCommand:outputCommand];
    LEDebugLog(@"Writing motor power command: %@", outputCommand.data);
}

- (void)writePiezoToneFrequency:(uint16_t)frequency milliseconds:(uint16_t)milliseconds connectID:(uint8_t)connectID
{
    LEOutputCommand *outputCommand = [LEOutputCommand commandWritePiezoToneFrequency:frequency milliseconds:milliseconds connectID:connectID];
    [self writeOutputCommand:outputCommand];
    LEDebugLog(@"Writing piezo tone play command: %@", outputCommand.data);
}

- (void)writePiezoToneStopForConnectID:(uint8_t)connectID
{
    LEOutputCommand *outputCommand = [LEOutputCommand commandWritePiezoToneStopForConnectID:connectID];
    [self writeOutputCommand:outputCommand];
    LEDebugLog(@"Writing piezo tone stop command: %@", outputCommand.data);
}

- (void)writeColorRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue connectID:(uint8_t)connectID
{
    LEOutputCommand *outputCommand = [LEOutputCommand commandWriteRGBLightRed:red green:green blue:blue connectId:connectID];
    [self writeOutputCommand:outputCommand];
    LEDebugLog(@"Writing RGB command: %@", outputCommand.data);
}

- (void)writeColorIndex:(uint8_t)index connectID:(uint8_t)connectID
{
    LEOutputCommand *outputCommand = [LEOutputCommand commandWriteRGBLightIndex:index connectId:connectID];
    [self writeOutputCommand:outputCommand];
    LEDebugLog(@"Writing RGB Index command: %@", outputCommand.data);
}

- (void)writeData:(NSData *)data connectID:(uint8_t)connectID
{
    LEOutputCommand *outputCommand = [LEOutputCommand commandWithDirectWriteThroughData:data connectID:connectID];
    [self writeOutputCommand:outputCommand];
    LEDebugLog(@"Direct write with data: @%", outputCommand.data);
}


- (void)writeOutputCommand:(LEOutputCommand *)command
{
    [self.service.peripheral writeValue:command.data forCharacteristic:self.outputCommandCharacteristic type:CBCharacteristicWriteWithoutResponse];
}


- (void)handleWriteResponseFromIOServiceWithCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!error) {
        LEDebugLog(@"Did write data %@", characteristic.value);
    } else {
        LEErrorLog(@"Failed to write data for characteristic %@", characteristic.descriptionWithName);
    }
}

- (void)handleUpdatedInputServiceCharacteristic:(CBCharacteristic *)characteristic
{
    if ([self.serviceDefinition.inputFormat matchesCharacteristic:characteristic]) {
        [self handleUpdatedInputFormatData:characteristic.value];
    } else if ([self.serviceDefinition.inputValue matchesCharacteristic:characteristic]) {
        [self handleUpdatedInputValueData:characteristic.value];
    }
}

- (void)handleUpdatedInputFormatData:(NSData *)data
{
    LEInputFormat *format = [LEInputFormat inputFormatWithData:data];
    if (format) {
        LEDebugLog(@"Did receive Input Format: %@", format.description);

        //If we already have input format with an earlier revision, delete all those
        //as all known formats must have the same version
        LEInputFormat *anyFormat = self.inputFormats.allValues.firstObject;
        if (anyFormat.revision != format.revision) {
            [self.inputFormats removeAllObjects];

        }

        self.inputFormats[@(format.connectID)] = format;

        __weak __typeof__(self) weakSelf = self;
        [_delegates foreach:^(id delegate, BOOL *stop) {
            LEConnectInfo *info = [delegate ioDidRequestConnectInfo:self];
            if (info.connectID == format.connectID) {
                [delegate io:weakSelf didReceiveInputFormat:format];
            }
        }];
    }
}

- (void)handleUpdatedInputValueData:(NSData *)data
{
    uint8_t valueFormatRevision;
    [data getBytes:&valueFormatRevision length:1];

    BOOL hasMoreValues = YES;
    NSUInteger byteIndex = 1; //first byte is revision

    NSMutableDictionary *idToValue = [NSMutableDictionary dictionary];

    while (hasMoreValues) {

        uint8_t valueConnectID;
        [data getBytes:&valueConnectID range:NSMakeRange(byteIndex, sizeof(valueConnectID))];
        LEInputFormat *format = self.inputFormats[@(valueConnectID)];

        if (self.inputFormats.count == 0) {
            LEDebugLog(@"Cannot parse value - has not yet received any Input Format from device");
            [self readInputFormatForConnectID:valueConnectID]; //HUB is sending data, so it must have an Input Format registered
            return;
        }

        if (!format) {
            LEDebugLog(@"No known Input Format for input with Connect ID %lx", (long) valueConnectID);
            return;
        }

        if (format.revision != valueFormatRevision) {
            LEDebugLog(@"Format revision %ld in received value does not match last received Input Format revision %ld", (long) valueFormatRevision, (long) format.revision);
            [self readInputFormatForConnectID:valueConnectID]; //HUB is sending data, so it must have an Input Format registered
            return;
        }

        byteIndex += sizeof(valueConnectID);
        NSData *value = [data subdataWithRange:NSMakeRange(byteIndex, format.numberOfBytes)];
        byteIndex += format.numberOfBytes;

        idToValue[@(valueConnectID)] = value;

        if (byteIndex >= data.length) {
            hasMoreValues = NO;
        }
    }

    __weak __typeof__(self) weakSelf = self;
    [_delegates foreach:^(id delegate, BOOL *stop) {
        LEConnectInfo *info = [delegate ioDidRequestConnectInfo:self];
        NSData *value = idToValue[@(info.connectID)];
        if (value) {
            [delegate io:weakSelf didReceiveValueData:value];
        }
    }];
}

@end