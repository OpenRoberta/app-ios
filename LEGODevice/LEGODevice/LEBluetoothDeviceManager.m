//
// Created by Søren Toft Odgaard on 8/15/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreBluetooth/CoreBluetooth.h>
#import "LEBluetoothDeviceManager.h"
#import "LEBluetoothDevice.h"
#import "LELogger+Project.h"
#import "LEBluetoothDevice+Project.h"
#import "LEIOServiceDefinition.h"
#import "LEDeviceServiceDefinition.h"
#import "LEBatteryServiceDefinition.h"
#import "LEDeviceInfoServiceDefinition.h"
#import "LEErrorCodes.h"
#import "LEDeviceManager.h"

static const NSTimeInterval LEBluetoothConnectionManagerRefreshDeviceListDefaultInterval = 1;
static const NSTimeInterval LEBluetoothConnectionManagerRefreshDeviceListMinimumInterval = 0.5;


@interface LEBluetoothDeviceManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSArray *primaryServiceUUIds;
@property (nonatomic, strong) NSArray *devices;
@property (nonatomic, strong) NSMutableDictionary *peripheralIdentifierToLastSeenTimeStamp;
@property (nonatomic, strong) NSTimer *cleanUpListOfDiscoveredDevicesTimer;
@property (nonatomic) BOOL scanningRequested;

@property (nonatomic, strong) NSMutableDictionary *deviceToConnectTimerDic;
@property (nonatomic, strong) NSMutableDictionary *peripheralToReconnectCount;

@end


@implementation LEBluetoothDeviceManager

- (id)initWithCentralManager:(CBCentralManager *)centralManager
{
    self = [super init];
    if (self) {
        self.centralManager = centralManager;
        self.centralManager.delegate = self;
        self.primaryServiceUUIds = @[
                [LEBluetoothServiceDefinition ioServiceDefinition].serviceUUID,
                [LEBluetoothServiceDefinition deviceServiceDefinition].serviceUUID,
                [LEBluetoothServiceDefinition batteryServiceDefinition].serviceUUID,
                [LEBluetoothServiceDefinition deviceInfoServiceDefinition].serviceUUID
        ];

        self.devices = [NSArray new];
        self.peripheralIdentifierToLastSeenTimeStamp = [NSMutableDictionary new];
        self.updateAdvertisingDevicesInterval = LEBluetoothConnectionManagerRefreshDeviceListDefaultInterval;
        self.deviceToConnectTimerDic = [NSMutableDictionary new];
        self.peripheralToReconnectCount = [NSMutableDictionary new];
        self.connectRequestTimeoutInterval = LEDefaultConnectRequestTimeout;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInterrogationFinished:) name:LEDeviceInterrogationFinishedNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)scan
{
    self.scanningRequested = YES;

    [self.cleanUpListOfDiscoveredDevicesTimer invalidate];
    self.cleanUpListOfDiscoveredDevicesTimer = [NSTimer scheduledTimerWithTimeInterval:self.updateAdvertisingDevicesInterval
            target:self selector:@selector(removeDevicesNotConnectedAndNotAdvertising) userInfo:nil repeats:YES];

    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        //It is important that "AllowDuplicates" is YES, otherwise the 'discoverPeripheral' method will only be invoked once when the peripheral is initially discovered.
        //and we use the advertising packages to read RSSI value and button state
        [self.centralManager scanForPeripheralsWithServices:@[ [LEBluetoothServiceDefinition deviceServiceDefinition].serviceUUID ] options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
        LEDebugLog(@"Scanning for peripherals started");
    } else {
        LEDebugLog(@"Scanning requested in state %lx, waiting for BT to speed on", (long) self.centralManager.state);
    }
}

- (void)stopScanning
{
    self.scanningRequested = NO;
    [self.cleanUpListOfDiscoveredDevicesTimer invalidate];

    for (LEBluetoothDevice *device in [self.devices copy]) {
        if (device.connectState == LEDeviceStateDisconnectedAdvertising || device.connectState == LEDeviceStateDisconnectedNotAdvertising) {
            [self removeDevice:device];
        }
    }

    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager stopScan];
    }
}

- (void)connectToDevice:(LEBluetoothDevice *)device
{
    LEDebugLog(@"Connecting to peripheral with name %@", device.name);
    [self.delegate deviceManager:self willStartConnectingToDevice:device];
    [self.centralManager connectPeripheral:device.peripheral options:nil];
    [self addConnectTimeoutTimerForDevice:device withTimeout:self.connectRequestTimeoutInterval];
}


- (void)cancelDeviceConnection:(LEBluetoothDevice *)device
{
    LEDebugLog(@"Disconnecting from peripheral with name %@", device.name);
    [self.centralManager cancelPeripheralConnection:device.peripheral];
    [self removeConnectTimeoutTimerForDevice:device];
}


- (void)deviceInterrogationFinished:(NSNotification *)notification
{
    LEBluetoothDevice *device = notification.object;
    [self resetReconnectCountForDevice:device];
    if ([self.delegate respondsToSelector:@selector(deviceManager:didFinishInterrogatingDevice:)]) {
        [self.delegate deviceManager:self didFinishInterrogatingDevice:device];
    }
}

- (void)setUpdateAdvertisingDevicesInterval:(NSTimeInterval)interval
{
    if (interval > LEBluetoothConnectionManagerRefreshDeviceListMinimumInterval) {
        _updateAdvertisingDevicesInterval = interval;
    } else {
        LEWarnLog(@"Cannot set update refresh adversiting list internval to %0.2f, will set to minimum allowed value %0.2f", interval, LEBluetoothConnectionManagerRefreshDeviceListMinimumInterval);
        _updateAdvertisingDevicesInterval = LEBluetoothConnectionManagerRefreshDeviceListMinimumInterval;
    }
}

- (NSArray *)allDevices
{
    return [self.devices sortedArrayUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"RSSI" ascending:NO] ]];
}

- (NSArray *)devicesInState:(LEDeviceState)connectState
{
    NSArray *filteredDevices = [self.devices filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"connectState == %lu", connectState]];

    if (connectState == LEDeviceStateDisconnectedAdvertising || connectState == LEDeviceStateConnecting) {
        filteredDevices = [filteredDevices sortedArrayUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"RSSI" ascending:NO] ]];
    }

    return filteredDevices;
}

- (NSArray *)visibleButDisconnectedDevices
{
    return [self.devices filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", @"connectState", @(LEDeviceStateDisconnectedAdvertising)]];
}

#pragma mark - Connect request timeout

- (void)connectRequestTimedOut:(NSTimer *)timer
{

    LEBluetoothDevice *device = timer.userInfo[@"device"];
    if (!device) {
        LEErrorLog(@"Received a connection time out but could not find device to cancel connect request for");
        return;
    }
    LEWarnLog(@"Connect request timed out for device: %@", device.peripheral.name);
    [self removeConnectTimeoutTimerForDevice:device];
    [self cancelDeviceConnection:device];
    NSError *error = [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeBluetoothConnectionTimeout userInfo:@{ NSLocalizedDescriptionKey : @"Connect request timed out" }];
    [self.delegate deviceManager:self didFailToConnectToDevice:device willAttemptAutoReconnect:NO error:error];
}

- (void)addConnectTimeoutTimerForDevice:(LEBluetoothDevice *)device withTimeout:(NSTimeInterval)timeout
{
    NSTimer *connectTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(connectRequestTimedOut:) userInfo:@{ @"device" : device } repeats:NO];
    self.deviceToConnectTimerDic[device.peripheral.identifier] = connectTimeoutTimer;
}

- (void)removeConnectTimeoutTimerForDevice:(LEBluetoothDevice *)device
{
    NSTimer *timer = self.deviceToConnectTimerDic[device.peripheral.identifier];
    [timer invalidate];
    [self.deviceToConnectTimerDic removeObjectForKey:device.peripheral.identifier];
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn && self.scanningRequested) {
        LEDebugLog(@"Bluetooth changed state to 'speed on'");
        [self scan];
    }
}


- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    @synchronized (self) {
        if (!peripheral.name) {
            return;
        }

        if (!RSSI || RSSI.intValue == 127) { //if newRSSI has as NSValue that is null, the intValue will return 127....sorry, I could not figure out how to do this check the 'right way'
            return;
        }

        LEBluetoothDevice *device = [self deviceWithPeripheral:peripheral];
        
        // don't register the device until it has received its name
        if (!device.name && !advertisementData[CBAdvertisementDataLocalNameKey]) {
            return;
        }
        
        if (!device) {
            LEDebugLog(@"Adding new peripheral %@", peripheral.name);
            device = [LEBluetoothDevice deviceWithPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
            device.advertising = YES;
            [self addDevice:device];
            if ([self.delegate respondsToSelector:@selector(deviceManager:deviceDidAppear:)]) {
                [self.delegate deviceManager:self deviceDidAppear:device];
            }
        } else {
            BOOL didStartAdvertising = !device.advertising; //If yes, this is the first call to 'didDiscoverPeripheral' after a disconnect
            device.advertising = YES;
            [device updateWithAdvertisementData:advertisementData RSSI:RSSI];

            if (didStartAdvertising && [self.delegate respondsToSelector:@selector(deviceManager:deviceDidAppear:)]) {
                [self.delegate deviceManager:self deviceDidAppear:device];
            }
        }
        if (peripheral.identifier) {
            self.peripheralIdentifierToLastSeenTimeStamp[peripheral.identifier] = [NSDate new];
        }
    }
}

- (void)removeDevicesNotConnectedAndNotAdvertising
{
    @synchronized (self) {
        NSDate *current = [NSDate new];
        NSArray *listToIterate = [self visibleButDisconnectedDevices];
        for (LEBluetoothDevice *device in listToIterate) {
            if (device.peripheral.identifier) {
                NSDate *lastSeenDate = self.peripheralIdentifierToLastSeenTimeStamp[device.peripheral.identifier];
                BOOL lastAdvertisePackageTooOld = [current timeIntervalSinceDate:lastSeenDate] > self.updateAdvertisingDevicesInterval;
                if (lastAdvertisePackageTooOld) {
                    device.advertising = NO;
                }
                if (device.peripheral.state == CBPeripheralStateDisconnected && lastAdvertisePackageTooOld) {
                    [self.peripheralIdentifierToLastSeenTimeStamp removeObjectForKey:device.peripheral.identifier];
                    [self removeDevice:device];
                    if ([self.delegate respondsToSelector:@selector(deviceManager:deviceDidDisappear:)]) {
                        [self.delegate deviceManager:self deviceDidDisappear:device];
                    }
                }
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    @synchronized (self) {
        //Discover appropriate services etc. - when we for instance discover a "motor service" send notification
        LEBluetoothDevice *device = [self deviceWithPeripheral:peripheral];

        if (!device) {
            LEDebugLog(@"Did not find device matching the peripheral, creating a new one %@", peripheral.name);
            device = [LEBluetoothDevice deviceWithPeripheral:peripheral advertisementData:nil RSSI:nil];
            [self addDevice:device];
            device.advertising = YES;
            if ([self.delegate respondsToSelector:@selector(deviceManager:deviceDidAppear:)]) {
                [self.delegate deviceManager:self deviceDidAppear:device];
            }
        }

        [self removeConnectTimeoutTimerForDevice:device];

        [device deviceDidConnect];

        if ([self.delegate respondsToSelector:@selector(deviceManager:didStartInterrogatingDevice:)]) {
            [self.delegate deviceManager:self didStartInterrogatingDevice:device];
        }

        [peripheral discoverServices:_primaryServiceUUIds];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    @synchronized (self) {
        LEErrorLog(@"Failed to connect to peripheral %@", peripheral.name);
        LEBluetoothDevice *device = [self deviceWithPeripheral:peripheral];
        if (!device) {
            LEWarnLog(@"Recieved a did fail to connect response, but could not find Device for corresponding peripheral");
            if ([self.delegate respondsToSelector:@selector(deviceManager:didFailToConnectToDevice:willAttemptAutoReconnect:error:)]) {
                [self.delegate deviceManager:self didFailToConnectToDevice:nil willAttemptAutoReconnect:NO error:error];
            }
            return;
        }

        [device cleanUp];
        [self removeConnectTimeoutTimerForDevice:device];

        BOOL shouldAttemptReconnect = [self shouldAllowReconnectToDevice:device];
        if ([self.delegate respondsToSelector:@selector(deviceManager:didFailToConnectToDevice:willAttemptAutoReconnect:error:)]) {
            [self.delegate deviceManager:self didFailToConnectToDevice:device willAttemptAutoReconnect:shouldAttemptReconnect error:error];
        }

        if (shouldAttemptReconnect) {
            [self reconnectToDevice:device];
        } else {
            [self removeDevice:device];
            [self resetReconnectCountForDevice:device];
        }
    }
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    @synchronized (self) {
        LEDebugLog(@"Did diconnect from peripheral %@", peripheral.name);
        LEBluetoothDevice *device = [self deviceWithPeripheral:peripheral];

        if (!device) {
            LEDebugLog(@"Did not find device matching the peripheral, creating a new one %@", peripheral.name);
            device = [LEBluetoothDevice deviceWithPeripheral:peripheral advertisementData:nil RSSI:nil];
            [self addDevice:device];
        }

        [device cleanUp];
        if (error) {
            if (error.code == 6) {
                //Connection lost e.g. due to out of range
                LEDebugLog(@"Connection lost to device: %@ [%@]", device.name, error.localizedDescription);
            } else if (error.code == 7) {
                //Happens e.g. when the user holds down the button on the device for a few seconds
                LEDebugLog(@"Connection closed from device %@: [%@]", device.name, error.localizedDescription);
                error = nil; //we do not want to treat this as an error
            } else {
                LEWarnLog(@"Connection closed unexpectedly to device %@: [%@]", device.name, error.localizedDescription);
            }
        }

        BOOL shouldAttemptReconnect = (error && [self shouldAllowReconnectToDevice:device]);
        if (shouldAttemptReconnect) {
            [self removeDevice:device];
        }

        if ([self.delegate respondsToSelector:@selector(deviceManager:didDisconnectFromDevice:willAttemptAutoReconnect:error:)]) {
            [self.delegate deviceManager:self didDisconnectFromDevice:device willAttemptAutoReconnect:shouldAttemptReconnect error:error];
        }

        if (shouldAttemptReconnect) {
            [self reconnectToDevice:device];
        } else {
            [self resetReconnectCountForDevice:device];
        }
    }
}

#pragma mark - Reconnect

- (void)resetReconnectCountForDevice:(LEBluetoothDevice *)device
{
    [self.peripheralToReconnectCount removeObjectForKey:device.peripheral.identifier];
}

- (void)reconnectToDevice:(LEBluetoothDevice *)device
{
    NSUInteger reconnectCount = ((NSNumber *) self.peripheralToReconnectCount[device.peripheral.identifier]).integerValue;
    self.peripheralToReconnectCount[device.peripheral.identifier] = @(reconnectCount + 1);
    [self connectToDevice:device];
}

- (BOOL)shouldAllowReconnectToDevice:(LEBluetoothDevice *)device
{
    if (!self.automaticReconnectOnConnectionLostEnabled) {
        return NO;
    }

    NSUInteger reconnectCount = ((NSNumber *) self.peripheralToReconnectCount[device.peripheral.identifier]).integerValue;
    return (reconnectCount < 1);
}


#pragma mark - Private helpers

- (void)addDevice:(LEBluetoothDevice *)device
{
    [[self mutableArrayValueForKey:@"devices"] addObject:device];
}

- (void)removeDevice:(LEBluetoothDevice *)device
{
    [[self mutableArrayValueForKey:@"devices"] removeObject:device];
}

- (LEBluetoothDevice *)deviceWithPeripheral:(CBPeripheral *)peripheral
{
    for (LEBluetoothDevice *device in self.devices) {
        if ([device.peripheral.identifier isEqual:peripheral.identifier]) {
            return device;
        }
    }
    return nil;
}

#pragma mark - KVO Compliance

+ (NSSet *)keyPathsForValuesAffectingAllDevices
{
    return [NSSet setWithObject:@"devices"];
}

@end