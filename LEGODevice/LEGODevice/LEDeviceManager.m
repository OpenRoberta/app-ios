//
//  LEDeviceManager.m
//  LEGODevice
//
//  Created by Jon Nørrelykke on 24/10/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "LEDeviceManager.h"
#import "LEBluetoothDeviceManager.h"
#import "LEBluetoothDevice.h"
#import "LELogger+Project.h"

@interface LEDeviceManager () <LEBluetoothDeviceManagerDelegate>

@property (nonatomic, strong) LEBluetoothDeviceManager *btDeviceManager;
@property (nonatomic, strong) NSMutableArray *bluetoothDevices;
@property (nonatomic, strong) LEMultiDelegate *delegates;

@end

@implementation LEDeviceManager

+ (LEDeviceManager *)sharedDeviceManager
{
    static LEDeviceManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.delegates = [LEMultiDelegate new];
        self.bluetoothDevices = [NSMutableArray new];
        CBCentralManager *centralManager = [[CBCentralManager alloc] initWithDelegate:nil queue:nil];
        self.btDeviceManager = [[LEBluetoothDeviceManager alloc] initWithCentralManager:centralManager];
        self.btDeviceManager.delegate = self;
        self.connectRequestTimeoutInterval = LEDefaultConnectRequestTimeout;
    }
    return self;
}

#pragma mark - Public methods

- (void)scan
{
    [self.btDeviceManager scan];
}

- (void)stopScanning
{
    [self.btDeviceManager stopScanning];
}

- (void)connectToDevice:(LEDevice *)device
{
    if ([device isKindOfClass:[LEBluetoothDevice class]]) {
        [self.btDeviceManager connectToDevice:(LEBluetoothDevice *) device];
    } else {
        LEErrorLog(@"Can only connect to devices of LEBluetoothDevice");
    }
}

- (void)setConnectRequestTimeoutInterval:(NSTimeInterval)interval
{
    _connectRequestTimeoutInterval = interval;
    self.btDeviceManager.connectRequestTimeoutInterval = interval;
}

- (void)setAutomaticReconnectOnConnectionLostEnabled:(BOOL)enabled
{
    _automaticReconnectOnConnectionLostEnabled = enabled;
    self.btDeviceManager.automaticReconnectOnConnectionLostEnabled = enabled;
}

- (void)cancelDeviceConnection:(LEDevice *)device
{
    if ([device isKindOfClass:[LEBluetoothDevice class]]) {
        [self.btDeviceManager cancelDeviceConnection:(LEBluetoothDevice *) device];
    } else {
        LEErrorLog(@"Can only disconnect to devices of LEBluetoothDevice");
    }

}

- (void)addDelegate:(id <LEDeviceManagerDelegate>)delegate
{
    [self.delegates addDelegate:delegate];
}

- (void)removeDelegate:(id <LEDeviceManagerDelegate>)delegate
{
    [self.delegates removeDelegate:delegate];
}

#pragma mark - Public properties
- (NSArray *)devicesInState:(LEDeviceState)connectState
{
    return [self.btDeviceManager devicesInState:connectState];
}

- (NSArray *)allDevices
{
    return self.btDeviceManager.allDevices;
}

#pragma mark - LEBluetoothDeviceManagerDelegate

- (void)deviceManager:(LEBluetoothDeviceManager *)manager deviceDidAppear:(LEBluetoothDevice *)btDevice
{
    if (![self.bluetoothDevices containsObject:btDevice]) {
        [self.bluetoothDevices addObject:btDevice];
    }
    [self.delegates foreachPerform:@selector(deviceManager:deviceDidAppear:) withObject:self withObject:btDevice];
}

- (void)deviceManager:(LEBluetoothDeviceManager *)manager deviceDidDisappear:(LEBluetoothDevice *)btDevice
{
    [self.bluetoothDevices removeObject:btDevice];
    [self.delegates foreachPerform:@selector(deviceManager:deviceDidDisappear:) withObject:self withObject:btDevice];
}

- (void)deviceManager:(LEBluetoothDeviceManager *)manager willStartConnectingToDevice:(LEBluetoothDevice *)device {
    [self.delegates foreachPerform:@selector(deviceManager:willStartConnectingToDevice:) withObject:self withObject:device];
}

- (void)deviceManager:(LEBluetoothDeviceManager *)manager didStartInterrogatingDevice:(LEBluetoothDevice *)device
{
    [self.delegates foreachPerform:@selector(deviceManager:didStartInterrogatingDevice:) withObject:self withObject:device];
}

- (void)deviceManager:(LEBluetoothDeviceManager *)manager didFinishInterrogatingDevice:(LEBluetoothDevice *)btDevice
{
    __weak __typeof__(self) weakSelf = self;
    [self.delegates foreach:^(id delegate, BOOL *stop) {
        if ([delegate respondsToSelector:@selector(deviceManager:didFinishInterrogatingDevice:)]) {
            [delegate deviceManager:weakSelf didFinishInterrogatingDevice:btDevice];
        }
    }];
}


- (void)deviceManager:(LEBluetoothDeviceManager *)manager didDisconnectFromDevice:(LEBluetoothDevice *)btDevice willAttemptAutoReconnect:(BOOL)autoReconnect error:(NSError *)error
{
    [self.bluetoothDevices removeObject:btDevice];
    __weak __typeof__(self) weakSelf = self;
    [self.delegates foreach:^(id delegate, BOOL *stop) {
        if ([delegate respondsToSelector:@selector(deviceManager:didDisconnectFromDevice:willAttemptAutoReconnect:error:)]) {
            [delegate deviceManager:weakSelf didDisconnectFromDevice:btDevice willAttemptAutoReconnect:autoReconnect error:error];
        }
    }];
}

- (void)deviceManager:(LEBluetoothDeviceManager *)manager didFailToConnectToDevice:(LEBluetoothDevice *)btDevice willAttemptAutoReconnect:(BOOL)autoReconnect error:(NSError *)error
{
    [self.bluetoothDevices removeObject:btDevice];
    __weak __typeof__(self) weakSelf = self;
    [self.delegates foreach:^(id delegate, BOOL *stop) {
        if ([delegate respondsToSelector:@selector(deviceManager:didFailToConnectToDevice:willAttemptAutoReconnect:error:)]) {
            [delegate deviceManager:weakSelf didFailToConnectToDevice:btDevice willAttemptAutoReconnect:autoReconnect error:error];
        }
    }];
}

#pragma mark - KVO Compliance

+ (NSSet *)keyPathsForValuesAffectingAllDevices
{
    return [NSSet setWithObject:@"btDeviceManager.allDevices"];
}

@end
