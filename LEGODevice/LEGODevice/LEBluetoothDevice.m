//
// Created by Søren Toft Odgaard on 9/6/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreBluetooth/CoreBluetooth.h>
#import "LEBluetoothDevice+Project.h"
#import "LEBluetoothIO.h"
#import "LELogger+Project.h"
#import "LEBluetoothHelper.h"
#import "LEIOServiceDefinition.h"
#import "LEDeviceServiceDefinition.h"
#import "LEErrorCodes.h"
#import "CBService+LEAdditional.h"
#import "LEServiceFactory.h"
#import "CBCharacteristic+LEAdditional.h"
#import "NSData+LEAdditional.h"
#import "NSArray+LEAdditional.h"
#import "LEDeviceInfoServiceDefinition.h"
#import "LEBatteryServiceDefinition.h"
#import "LEGODevice.h"
#import "LEConnectInfo+Project.h"
#import "LEDeviceInfo+Project.h"
#import "LERevision+Project.h"

static const NSUInteger kNumberOfRSSIValuesToAverage = 10;
static const NSUInteger kSizeOfAttachedIOData = 12;

@interface LEBluetoothDevice ()

@property (nonatomic, strong) NSDictionary *serviceData;

@property (nonatomic, strong) NSMutableArray *rssiValues;
@property (nonatomic) NSUInteger rssiIndex;
@property (nonatomic, strong) NSNumber *averageRSSI;

//LEGO IO Service
@property (nonatomic, strong) LEIOServiceDefinition *ioServiceDefinition;
@property (nonatomic, strong) LEBluetoothIO *bluetoothIO;

//LEGO Device Service
@property (nonatomic, strong) LEDeviceServiceDefinition *deviceServiceDefinition;
@property (nonatomic, strong) CBCharacteristic *nameCharacteristic;
@property (nonatomic, strong) CBCharacteristic *iosCharacteristic;
@property (nonatomic, strong) CBCharacteristic *buttonCharacteristic;
@property (nonatomic, strong) CBCharacteristic *lowVoltageAlertCharacteristic;

//BatteryService
@property (nonatomic, strong) CBCharacteristic *batteryLevelCharacteristic;

//DeviceInfoService
@property (nonatomic, strong) LEDeviceInfoServiceDefinition *deviceInfoServiceDefinition;
@property (nonatomic, strong) CBCharacteristic *firmwareRevisionCharacteristic;
@property (nonatomic, strong) CBCharacteristic *hardwareRevisionCharacteristic;
@property (nonatomic, strong) CBCharacteristic *softwareRevisionCharacteristic;
@property (nonatomic, strong) CBCharacteristic *manufacturerCharacteristic;

@property (nonatomic, readwrite) BOOL interrogationFinished;
@property (nonatomic, readwrite, getter=isAdvertising) BOOL advertising;

@property (nonatomic, strong) NSDictionary *advertisementData;

//Overwritten from LEDevice
@property (nonatomic, strong) NSNumber *batteryLevel;
@property (nonatomic, readwrite) BOOL lowVoltage;
@property (nonatomic, readonly) LEDeviceCategory category;
@property (nonatomic, readonly) LEDeviceFunction supportedFunctions;
@property (nonatomic, readonly) NSUInteger lastConnectedNetworkId;



@end


@implementation LEBluetoothDevice

//Readonly attributes from parent class must be synthesized for write access
@synthesize buttonPressed = _buttonPressed;
@synthesize category = _category;
@synthesize supportedFunctions = _supportedFunctions;
@synthesize lastConnectedNetworkId = _lastConnectedNetworkId;
@synthesize services = _services;
@synthesize batteryLevel = _batteryLevel;
@synthesize lowVoltage = _lowVoltageAlert;

@synthesize deviceInfo = _deviceInfo;

//We want to be able to access this without getting the side effects of the setter-method
@synthesize name = _name;



#pragma mark - Initializing an LEBluetoothDevice

- (id)initWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSParameterAssert(peripheral != nil);
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        self.peripheral.delegate = self;
        [self resetState];
        self.ioServiceDefinition = [LEBluetoothServiceDefinition ioServiceDefinition];
        self.deviceServiceDefinition = [LEBluetoothServiceDefinition deviceServiceDefinition];
        self.deviceInfoServiceDefinition = [LEBluetoothServiceDefinition deviceInfoServiceDefinition];
        [self updateWithAdvertisementData:advertisementData RSSI:RSSI];

        _deviceInfo = [LEDeviceInfo deviceInfo];
    }
    return self;
}

+ (LEBluetoothDevice *)deviceWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    return [[LEBluetoothDevice alloc] initWithPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
}

#pragma  mark - Public Properties

- (LEDeviceState)connectState
{
    switch (self.peripheral.state) {
        case CBPeripheralStateDisconnected:
            if (self.isAdvertising) {
                return LEDeviceStateDisconnectedAdvertising;
            } else {
                return LEDeviceStateDisconnectedNotAdvertising;
            }
        case CBPeripheralStateConnecting:
            return LEDeviceStateConnecting;
        case CBPeripheralStateConnected: {
            if (self.interrogationFinished) {
              return LEDeviceStateInterrogationFinished;
            } else {
                return LEDeviceStateInterrogating;
            }
        }
        case CBPeripheralStateDisconnecting:
            break;
    }
    LEWarnLog(@"Unknown connect state %ld of peripheral", (long) self.peripheral.state);
    return LEDeviceStateDisconnectedNotAdvertising;
}

- (NSString *)deviceId
{
    return self.peripheral.identifier.UUIDString;
}

- (void)setName:(NSString *)name
{
    if (self.connectState != LEDeviceStateInterrogationFinished) {
        LEWarnLog(@"Ignoring call to set device name - not connected to device");
        return;
    }

    NSString *oldName = self.name;
    _name = [name copy];

    NSData *dataToWrite = (name) ? [name dataUsingEncoding:NSUTF8StringEncoding] : [NSData data];

    //We use an optimistic approach when setting the name - we assume that the write is successful. If
    //we get an didWriteValueForCharacteristic with an error, we will revert the value and notify through the delegate
    [self.peripheral writeValue:dataToWrite forCharacteristic:self.nameCharacteristic type:CBCharacteristicWriteWithResponse];

    [_delegates foreachPerform:@selector(device:didChangeNameFrom:to:) withObject:self withObject:oldName withObject:self.name];
}

//Create setter for property that is readonly in parent
- (void)setServices:(NSArray *)services
{
    _services = services;
}

//Create setter for property that is readonly in parent
- (void)setButtonPressed:(BOOL)pressed
{
    _buttonPressed = pressed;
}


#pragma mark - Handle updated Advertisement data

- (void)updateWithAdvertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    LEVerboseLog(@"Updating with RSSI %@ and adv data %@", RSSI, advertisementData);
    [self calculateAverageRSSI:RSSI];
    
    // merge existing advertisement date with the one received
    NSMutableDictionary *newAdvertisementData = [[NSMutableDictionary alloc] initWithDictionary:_advertisementData];
    [newAdvertisementData addEntriesFromDictionary:advertisementData];
    self.advertisementData = [newAdvertisementData copy];

    NSString *oldName = self.name;
    NSString *newName = advertisementData[CBAdvertisementDataLocalNameKey];
    if (newName && ![newName isEqual:oldName]) {
        _name = newName;
        [_delegates foreach:^(id delegate, BOOL *stop) {
            if ([delegate respondsToSelector:@selector(device:didChangeNameFrom:to:)]) {
                [delegate device:self didChangeNameFrom:oldName to:_name];
            }
        }];
    }
    
    NSDictionary *newServiceData = advertisementData[CBAdvertisementDataServiceDataKey];
    if (!newServiceData) {
        return;
    }

    self.serviceData = newServiceData;

    NSData *serviceDataContent = newServiceData[self.deviceServiceDefinition.shortServiceUUID];
    if (!serviceDataContent) {
        LEErrorLog(@"Did not find any ServiceData for service %@", self.deviceServiceDefinition.shortServiceUUID);
        return;
    }

    Byte *bytes = ((Byte *) [serviceDataContent bytes]);
    if (serviceDataContent.length >= 1) {
        Byte buttonState = bytes[0];
        [self updateButtonStateFromByte:buttonState];
    }
    if (serviceDataContent.length >= 2) {
        _category = bytes[1];
    }
    if (serviceDataContent.length >= 3) {
        _supportedFunctions = bytes[2];
    }

    if (serviceDataContent.length >= 4) {
        _lastConnectedNetworkId = bytes[3];
    }
}


- (void)updateButtonStateFromByte:(Byte)buttonState
{
    BOOL oldButtonPressedState = self.buttonPressed;
    self.buttonPressed = (buttonState == 1);

    if (self.buttonPressed != oldButtonPressedState) {
        LEDebugLog(@"Button %@", self.buttonPressed ? @"pushed" : @"released");
        [_delegates foreach:^(id delegate, BOOL *stop) {
            if ([delegate respondsToSelector:@selector(device:didChangeButtonState:)]) {
                [delegate device:self didChangeButtonState:self.buttonPressed];
            }
        }];
    }
}

- (void)calculateAverageRSSI:(NSNumber *)newRSSI
{
    if (!newRSSI || newRSSI.intValue == 127) { //if newRSSI has as NSValue that is null, the intValue will return 127....sorry, I could not figure out how to do this check the 'right way'
        return;
    }

    if ([self.rssiValues count] < kNumberOfRSSIValuesToAverage) {
        //until we have reached the first kNumberOfRSSIValuesToAverage values, just add them
        [self.rssiValues addObject:newRSSI];
    } else {
        //after having received the 10 first values, replace existing value at rssiIndex
        self.rssiValues[self.rssiIndex] = newRSSI;
        self.rssiIndex++;
    }

    if (self.rssiIndex <= kNumberOfRSSIValuesToAverage) {
        //Sort the values in a list a pick the value in the middle of the list as the average value
        //which is a simple way to ignore outliers.
        NSArray *sortedRSSIValues = [self.rssiValues sortedArrayUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"intValue" ascending:YES] ]];
        NSInteger middleIndex = [sortedRSSIValues count] / 2; //intentionally assign to int, to round down result to nearest integer
        self.averageRSSI = sortedRSSIValues[middleIndex];
    }
    if (self.rssiIndex == kNumberOfRSSIValuesToAverage) {
        self.rssiIndex = 0;
    }
}


- (NSNumber *)RSSI
{
    return self.averageRSSI;
}

#pragma mark- CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    LEDebugLog(@"Did discover services for peripheral: %@", peripheral.name);

    if ([peripheral.services count] == 0) {
        LEErrorLog(@"Did not find any services for peripheral %@", peripheral.name);
    }

    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        LEBluetoothServiceDefinition *serviceDefinition = [LEBluetoothServiceDefinition serviceDefinitionWithUUID:service.UUID];
        if (serviceDefinition) {
            LEDebugLog(@"Adding service: %@", service.descriptionWithName);
        } else {
            LEErrorLog(@"Did discover service with unknown UUID %@", service.UUID.data);
            return;
        }

        //We start by only discovering the Bluetooth Device Info service. Once we are sure that we are talking
        //to a Device with a supported firmware version, we discover characteristics for the remaining services
        if ([[LEDeviceInfoServiceDefinition sharedInstance] matchesService:service]) {
            [peripheral discoverCharacteristics:serviceDefinition.characteristicUUIDs forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    LEWarnLog(@"Did modify services for peripheral%@ but dynamic modifications of services are currenlty not supported by the Lego Device SDK", peripheral.name);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    LEWarnLog(@"Did not expect to discover included services for peripheral %@", peripheral.name);
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        LEErrorLog(@"%@", error.localizedDescription);
        [_delegates foreachPerform:@selector(device:didFailToAddServiceWithError:) withObject:self withObject:error];
        return;
    }

    LEBluetoothServiceDefinition *definition = [LEBluetoothServiceDefinition serviceDefinitionWithUUID:service.UUID];

    if (!definition) {
        LEErrorLog(@"Did discover unknown service with UUID: %@", service.UUID.data);
        NSString *errorMessage = [NSString stringWithFormat:@"LEGO Device SDK does not recognize service with UUID %@", service.UUID.data];
        NSError *error1 = [NSError
                errorWithDomain:LEDeviceErrorDomain
                code:LEErrorCodeBluetoothUnknownServiceUUID
                userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
        [_delegates foreachPerform:@selector(device:didFailToAddServiceWithError:) withObject:self withObject:error1];
        return;
    }

    NSError *validationError = [definition validateDefinitionIsSatisfiedByService:service];
    if (validationError) {
        [_delegates foreachPerform:@selector(device:didFailToAddServiceWithError:) withObject:self withObject:validationError];
        return;
    }

    LEDebugLog(@"Did discover characteristics for %@", definition.serviceName);
    LEInfoLog(@"%@ sucessfully added", definition.serviceName);

    if ([[LEBluetoothServiceDefinition deviceInfoServiceDefinition] matchesService:service]) {
        LEDeviceInfoServiceDefinition *deviceInfoServiceDefinition = (LEDeviceInfoServiceDefinition *) definition;
        self.firmwareRevisionCharacteristic = [LEBluetoothHelper characteristicWithUUID:deviceInfoServiceDefinition.firmwareRevision.UUID inService:service];
        self.hardwareRevisionCharacteristic = [LEBluetoothHelper characteristicWithUUID:deviceInfoServiceDefinition.hardwareRevision.UUID inService:service];
        self.softwareRevisionCharacteristic = [LEBluetoothHelper characteristicWithUUID:deviceInfoServiceDefinition.softwareRevision.UUID inService:service];
        self.manufacturerCharacteristic = [LEBluetoothHelper characteristicWithUUID:deviceInfoServiceDefinition.manufacturerName.UUID inService:service];
        [self.peripheral readValueForCharacteristic:self.firmwareRevisionCharacteristic];
        if (self.hardwareRevisionCharacteristic) {
            [self.peripheral readValueForCharacteristic:self.hardwareRevisionCharacteristic];
        }
        [self.peripheral readValueForCharacteristic:self.softwareRevisionCharacteristic];
        [self.peripheral readValueForCharacteristic:self.manufacturerCharacteristic];
    } else if ([[LEBluetoothServiceDefinition deviceServiceDefinition] matchesService:service]) {
        self.nameCharacteristic = [LEBluetoothHelper characteristicWithUUID:self.deviceServiceDefinition.deviceName.UUID inService:service];
        self.iosCharacteristic = [LEBluetoothHelper characteristicWithUUID:self.deviceServiceDefinition.attachedIO.UUID inService:service];
        self.buttonCharacteristic = [LEBluetoothHelper characteristicWithUUID:self.deviceServiceDefinition.deviceButton.UUID inService:service];
        self.lowVoltageAlertCharacteristic = [LEBluetoothHelper characteristicWithUUID:self.deviceServiceDefinition.lowVoltageAlert.UUID inService:service];

        [self.peripheral readValueForCharacteristic:self.nameCharacteristic];
        if (self.nameCharacteristic) {
            LEInfoLog(@"Succesfully added device 'name' characteristic");
        }
        if (self.iosCharacteristic) {
            [service.peripheral setNotifyValue:YES forCharacteristic:self.iosCharacteristic];
            LEInfoLog(@"Succesfully added device 'Attached IO' characteristic");
        }
        if (self.buttonCharacteristic) {
            [service.peripheral setNotifyValue:YES forCharacteristic:self.buttonCharacteristic];
            LEInfoLog(@"Succesfully added device 'Button state' characteristic");
        }
        if (self.lowVoltageAlertCharacteristic) {
            [service.peripheral setNotifyValue:YES forCharacteristic:self.lowVoltageAlertCharacteristic];
            LEInfoLog(@"Succesfully added device 'Low Voltage Alert' characteristic");
        }
    } else if ([[LEBluetoothServiceDefinition ioServiceDefinition] matchesService:service]) {
        self.bluetoothIO = [LEBluetoothIO bluetoothIOWithService:service];
        if (!self.interrogationFinished) {
            self.interrogationFinished = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:LEDeviceInterrogationFinishedNotification object:self];
        }
    } else if ([[LEBluetoothServiceDefinition batteryServiceDefinition] matchesService:service]) {
        LEBatteryServiceDefinition *batteryServiceDefinition = (LEBatteryServiceDefinition *) definition;
        self.batteryLevelCharacteristic = [LEBluetoothHelper characteristicWithUUID:batteryServiceDefinition.batteryLevel.UUID inService:service];
        [self.peripheral readValueForCharacteristic:self.batteryLevelCharacteristic];
        [self.peripheral setNotifyValue:YES forCharacteristic:self.batteryLevelCharacteristic];
    } else {
        LEWarnLog(@"Discovered characteristics for unknown service with UUID %@", service.UUID.data);
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        LEErrorLog(@"Failed to update characteristic %@", [error localizedDescription]);
        return;
    } else {
        LEVerboseLog(@"Update for characteristic: %@ with value %@", characteristic.UUID.data, characteristic.value);
    }

    if ([[LEBluetoothServiceDefinition ioServiceDefinition] matchesService:characteristic.service]) {
        [self.bluetoothIO handleUpdatedInputServiceCharacteristic:characteristic];
    } else if ([self.deviceServiceDefinition matchesService:characteristic.service]) {
        [self handleUpdatedDeviceServiceCharacteristic:characteristic];
    } else if ([self.deviceInfoServiceDefinition matchesService:characteristic.service]) {
        [self handleUpdatedDeviceInfoServiceCharacteristic:characteristic];
    } else if ([self.batteryLevelCharacteristic isEqual:characteristic]) {
        [self handleUpdatedBatteryLevelCharacteristic:characteristic];
    }  else {
        LEWarnLog(@"Received update for unkown characteristic: %@", characteristic);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        LEErrorLog(@"Failed to write value for characteristic %@ with error %@",
                        characteristic.descriptionWithName,
                        error.localizedDescription);
    }

    if ([self.ioServiceDefinition matchesService:characteristic.service]) {
        [self.bluetoothIO handleWriteResponseFromIOServiceWithCharacteristic:characteristic error:error];
    } else if ([self.deviceServiceDefinition matchesService:characteristic.service]) {
        [self handleWriteResponseFromDeviceServiceWithCharacteristic:characteristic error:error];
    } else {
        LEWarnLog(@"Received a did-write characteristic value for characteristic %@, but did not find a service to deliver it to", characteristic.descriptionWithName);
    }
}

- (void)handleWriteResponseFromDeviceServiceWithCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error && [characteristic isEqual:self.nameCharacteristic]) {
        //If the name was not written - make sure we read and restore to the value on the device
        [self.peripheral readValueForCharacteristic:self.nameCharacteristic];
    }
}

- (void)addService:(LEService *)service
{
    self.services = [self.services arrayByAddingObject:service];
    self.services = [self.services sortedArrayUsingDescriptors:@[ [[NSSortDescriptor alloc] initWithKey:@"connectInfo.connectID" ascending:YES] ]];
}

- (void)removeService:(LEService *)service
{
    self.services = [self.services arrayByRemovingObject:service];
}

- (void)deviceDidConnect
{
    self.rssiValues = [NSMutableArray arrayWithCapacity:kNumberOfRSSIValuesToAverage];
    
    // Force KVO change notification to be emitted for non-KVO compliant CBPeripheral.state
    [self.peripheral willChangeValueForKey:@"state"];
    [self.peripheral didChangeValueForKey:@"state"];
}


- (void)cleanUp
{
    LEDebugLog(@"Cleaning up peripheral %@", self.name);
    [self resetState];
}

- (void)resetState
{
    self.serviceData = nil;
    self.interrogationFinished = NO;
    _deviceInfo = [LEDeviceInfo deviceInfo];

    self.rssiIndex = 0;
    self.rssiValues = [NSMutableArray arrayWithCapacity:kNumberOfRSSIValuesToAverage];
    self.averageRSSI = nil;

    _advertising = NO;

    self.services = @[ ];

    self.batteryLevel = nil;
    
    //Do not reset things set in 'advertising' as it is possible to reconnect to a device
    //without ever receiving a advertising package (e.g. on automatic reconnect)
    
    // Force KVO change notification to be emitted for non-KVO compliant CBPeripheral.state
    [self.peripheral willChangeValueForKey:@"state"];
    [self.peripheral didChangeValueForKey:@"state"];
}


#pragma mark - Handle updated characteristic data

- (void)handleUpdatedDeviceServiceCharacteristic:(CBCharacteristic *)characteristic
{
    if ([self.deviceServiceDefinition.deviceName matchesCharacteristic:characteristic]) {
        NSString *oldName = self.name;
        NSString *newName = [[NSString alloc] initWithData:[characteristic.value dataByTrimmingAllBytesFromFirstZero] encoding:NSUTF8StringEncoding];
        LEDebugLog(@"Received new device name: %@", newName);
        _name = newName;

        if (![newName isEqualToString:oldName]) {
            [_delegates foreachPerform:@selector(device:didChangeNameFrom:to:) withObject:self withObject:oldName withObject:newName];
        }
    } else if ([self.deviceServiceDefinition.attachedIO matchesCharacteristic:characteristic]) {
        LEDebugLog(@"Received characteristics for attacthed IOs: %@", characteristic.value);
        [self handleAttachedIOData:characteristic.value];
    } else if ([self.deviceServiceDefinition.deviceButton matchesCharacteristic:characteristic]) {
        LEDebugLog(@"Received update for button state characteristic: %@", characteristic.value);
        if (characteristic.value.length != 1) {
            LEErrorLog(@"Unexpected lenght of button state characteristic, expected 1 but was %lu", characteristic.value.length);
            return;
        }

        uint8_t newStateInt;
        [characteristic.value getBytes:&newStateInt length:1];

        BOOL oldState = self.buttonPressed;
        self.buttonPressed = (newStateInt == 1);

        if (oldState != self.buttonPressed) {
            __weak __typeof__(self) weakSelf = self;
            [_delegates foreach:^(id delegate, BOOL *stop) {
                if ([delegate respondsToSelector:@selector(device:didChangeButtonState:)]) {
                    [delegate device:weakSelf didChangeButtonState:self.buttonPressed];
                }
            }];
        }
    } else if ([self.deviceServiceDefinition.lowVoltageAlert matchesCharacteristic:characteristic]) {
        LEDebugLog(@"Received updated value for lowVoltageAlert %@", characteristic.value);
        [self handleUpdatedLowVoltageAlertCharacteristic:characteristic];
    } else {
        LEWarnLog(@"Received updated value for unkown characteristic %@", characteristic);
    }
}

- (void)handleAttachedIOData:(NSData *)data
{
    //Format for attach: {0: deviceId, 1: attached|detached, 2: hubIndex, 3: ioType, 4-8: hwVersion, 8-12: fwVersion}
    //Format for detach: {0: deviceId, 1: attached|detached }
    if (data.length < 2) {
        NSString *errorMessage = [NSString stringWithFormat:@"Did receive IO attached/detached notification from Device with size %lu, must be size %lu for attached and size 2 for detached",
                                                            (unsigned long) data.length, (unsigned long) kSizeOfAttachedIOData];
        LEErrorLog(@"%@", errorMessage);
        NSError *error = [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeInternalError userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
        [_delegates foreachPerform:@selector(device:didFailToAddServiceWithError:) withObject:self withObject:error];
        return;
    }

    uint8_t connectID;
    uint8_t attached;
    [data getBytes:&connectID range:NSMakeRange(0, 1)];
    [data getBytes:&attached range:NSMakeRange(1, 1)];
    if (attached == 0) {
        LEService *service = [self serviceWithConnectID:connectID];
        if (service) {
            [self removeService:service];
            [_delegates foreachPerform:@selector(device:didRemoveService:) withObject:self withObject:service];
            LEInfoLog(@"Removed input/output: %@", service.connectInfo);
        } else {
            LEWarnLog(@"Recieved notification for detached IO with unknown connect id %lu", (unsigned long) connectID);
        }
    } else {
        if (data.length != kSizeOfAttachedIOData) {
            NSString *errorMessage = [NSString stringWithFormat:@"Did receive IO attached notification from Device with size %lu, must be size %lu",
                                                                (unsigned long) data.length, (unsigned long) kSizeOfAttachedIOData];
            LEErrorLog(@"%@", errorMessage);
            NSError *error = [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeInternalError userInfo:@{ NSLocalizedDescriptionKey : errorMessage }];
            [_delegates foreachPerform:@selector(device:didFailToAddServiceWithError:) withObject:self withObject:error];
            return;
        }

        uint8_t hubIndex;
        uint8_t ioType;
        [data getBytes:&hubIndex range:NSMakeRange(2, 1)];
        [data getBytes:&ioType range:NSMakeRange(3, 1)];
        NSData *hwRevision = [data subdataWithRange:NSMakeRange(4, 4)];
        NSData *fwRevision = [data subdataWithRange:NSMakeRange(8, 4)];
        LEConnectInfo *connectInfo = [LEConnectInfo connectInfoWithConnectID:connectID hubIndex:hubIndex type:ioType
                hardwareVersion:[LERevision revisionWithData:hwRevision] firmwareVersion:[LERevision revisionWithData:fwRevision]];

        LEService *service = [LEServiceFactory serviceWithConnectInfo:connectInfo io:self.bluetoothIO device:self];
        if ([self.services containsObject:service]) {
            LEWarnLog(@"Will ignore duplicate notification for attached IO: %@", connectInfo);
            return;
        }

        if (service) {
            [self addService:service];
            LEInfoLog(@"Added input/output %@", service.connectInfo.debugDescription);
            [_delegates foreachPerform:@selector(device:didAddService:) withObject:self withObject:service];
        }
    }
}

- (void)handleUpdatedDeviceInfoServiceCharacteristic:(CBCharacteristic *)characteristic
{
    NSString *valueString = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    if ([self.deviceInfoServiceDefinition.firmwareRevision matchesCharacteristic:characteristic]) {
        _deviceInfo = [self.deviceInfo deviceInfoBySettingFirmwareRevisionString:valueString];
    } else if ([self.deviceInfoServiceDefinition.hardwareRevision matchesCharacteristic:characteristic]) {
        _deviceInfo = [self.deviceInfo deviceInfoBySettingHardwareRevisionString:valueString];
    } else if ([self.deviceInfoServiceDefinition.softwareRevision matchesCharacteristic:characteristic]) {
        _deviceInfo = [self.deviceInfo deviceInfoBySettingSoftwareRevisionString:valueString];
    } else if ([self.deviceInfoServiceDefinition.manufacturerName matchesCharacteristic:characteristic]) {
        _deviceInfo = [self.deviceInfo deviceInfoBySettingManufactureName:valueString];
    }

    //We have received values for all required device info characteristics
    if (self.deviceInfo.isComplete) {
        LERevision *firmwareRevisionTestedWithSDK = [LERevision revisionWithString:LE_BLUETOOTH_DEVICE_FIRMWARE_VERSION];
        LERevision *deviceFirmwareRevision = self.deviceInfo.firmwareRevision;

        
        __block NSError *error = nil;
        if (deviceFirmwareRevision.majorVersion <= firmwareRevisionTestedWithSDK.majorVersion) {
            LEInfoLog(@"Did find Device with firmware supported by SDK - querying characteristics for remaining services");
            for (CBService *service in self.peripheral.services) {
                LEBluetoothServiceDefinition *serviceDefinition = [LEBluetoothServiceDefinition serviceDefinitionWithUUID:service.UUID];

                //The Device Firmware is supported - query for characteristics for all remaining discovered services
                if (![[LEDeviceInfoServiceDefinition sharedInstance] matchesService:service]) {
                    [self.peripheral discoverCharacteristics:serviceDefinition.characteristicUUIDs forService:service];
                }

            }

            if (deviceFirmwareRevision.majorVersion == firmwareRevisionTestedWithSDK.majorVersion && deviceFirmwareRevision.minorVersion > firmwareRevisionTestedWithSDK.minorVersion) {
                LEWarnLog(@"SDK is tested to work with Device Firmware version %@ but is connected to a Device with Firmware version %@. \n"
                        "All Device features may not be supported by SDK.", firmwareRevisionTestedWithSDK, deviceFirmwareRevision);
            }
        } else {
            LEErrorLog(@"Did connect to Device with firmware version %@ where minimum required major version is %lu",
                            deviceFirmwareRevision, (unsigned long) firmwareRevisionTestedWithSDK.majorVersion);
            error = [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeBluetoothUnsupportedFirmwareVersion
                    userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Device firmware version %@ not supported by SDK, SDK requires firmware major version %lu",
                                                                                       deviceFirmwareRevision,
                                                                                       (unsigned long) firmwareRevisionTestedWithSDK.majorVersion] }];
        }


        __weak __typeof__(self) weakSelf = self;
        [_delegates foreach:^(id delegate, BOOL *stop) {
            if ([delegate respondsToSelector:@selector(device:didUpdateDeviceInfo:error:)]) {
                [delegate device:weakSelf didUpdateDeviceInfo:self.deviceInfo error:error];
            }
        }];
    }
}

- (void)handleUpdatedBatteryLevelCharacteristic:(CBCharacteristic *)characteristic
{
    LEDebugLog(@"Received new batterylevel %@", characteristic.value);
    if (characteristic.value.length == 1) {
        uint8_t newLevel;
        [characteristic.value getBytes:&newLevel length:1];
        self.batteryLevel = @(newLevel);
        __weak __typeof__(self) weakSelf = self;
        [_delegates foreach:^(id delegate, BOOL *stop) {
            if ([delegate respondsToSelector:@selector(device:didUpdateBatteryLevel:)]) {
                [delegate device:weakSelf didUpdateBatteryLevel:self.batteryLevel];
            }
        }];
    }
}

- (void)handleUpdatedLowVoltageAlertCharacteristic:(CBCharacteristic *)characteristic
{
    LEDebugLog(@"Received new low voltage alert %@", characteristic.value);
    if (characteristic.value.length == 1) {
        uint8_t newLevel;
        [characteristic.value getBytes:&newLevel length:1];
        self.lowVoltage = (newLevel == 1);
        __weak __typeof__(self) weakSelf = self;
        [_delegates foreach:^(id delegate, BOOL *stop) {
            if ([delegate respondsToSelector:@selector(device:didUpdateLowVoltageState:)]) {
                [delegate device:weakSelf didUpdateLowVoltageState:self.lowVoltage];
            }
        }];
    }
}

- (LEService *)serviceWithConnectID:(uint8_t)connectID
{
    for (LEService *service in self.services) {
        if (service.connectInfo.connectID == connectID) {
            return service;
        }
    }
    return nil;
}

#pragma mark - Equals and Hash

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![[other class] isEqual:[self class]])
        return NO;

    return [self isEqualToDevice:other];
}

- (BOOL)isEqualToDevice:(LEDevice *)device
{
    if (![device isKindOfClass:[self class]]) return NO;
    LEBluetoothDevice *btDevice = (LEBluetoothDevice *) device;

    if (self == btDevice)
        return YES;
    if (btDevice == nil)
        return NO;
    if (self.peripheral != btDevice.peripheral && ![self.peripheral isEqual:btDevice.peripheral])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    return [self.peripheral hash];
}

#pragma mark - KVO Compliance

+ (NSSet *)keyPathsForValuesAffectingConnectState
{
    return [NSSet setWithObjects:@"peripheral.state", @"advertising", @"interrogationFinished", nil];
}

+ (NSSet *)keyPathsForValuesAffectingRSSI
{
    return [NSSet setWithObject:@"averageRSSI"];
}

@end
