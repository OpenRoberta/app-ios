//
// Created by Søren Toft Odgaard on 25/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEService+Project.h"
#import "LEInputFormat.h"
#import "LELogger+Project.h"
#import "LEDataFormat.h"
#import "LEErrorCodes.h"
#import "NSSet+LEAdditional.h"


static const int kFirstInternalHubIndex = 50;

@interface LEService () <LEIODelegate>

@property (nonatomic, readwrite) NSData *valueData;
@property (nonatomic, readwrite) LEInputFormat *inputFormat;
@property (nonatomic, readwrite) NSSet *validDataFormats;

@end

@implementation LEService {
    LEMultiDelegate *_delegates;
    LEIO *_io;
    __weak LEDevice *_device;
}


- (instancetype)initWithConnectInfo:(LEConnectInfo *)connectInfo io:(LEIO *)io
{
    NSAssert(connectInfo != nil, @"Cannot instantiate service with nil Connect Info");
    NSAssert(io != nil, @"Cannot instantiate service with nill LEIO");
    self = [super init];
    if (self) {
        _io = io;
        [_io addDelegate:self];
        _connectInfo = connectInfo;
        _delegates = [LEMultiDelegate multiDelegate];
    }
    return self;

}

+ (instancetype)serviceWithConnectInfo:(LEConnectInfo *)connectInfo io:(LEIO *)io
{
    return [[self alloc] initWithConnectInfo:connectInfo io:io];
}

- (void)setDevice:(LEDevice *)device
{
    _device = device;
}

- (LEDevice *)device
{
    return _device;
}


#pragma mark - Delegates

- (void)addDelegate:(id <LEServiceDelegate>)delegate
{
    [self.delegates addDelegate:delegate];
}

- (void)removeDelegate:(id <LEServiceDelegate>)delegate
{
    [self.delegates removeDelegate:delegate];
}

- (LEMultiDelegate *)delegates
{
    return _delegates;
}

- (LEIO *)io
{
    return _io;
}

- (BOOL)isInternalService
{
    return self.connectInfo.hubIndex >= kFirstInternalHubIndex;
}


#pragma mark - Input Format

- (void)updateInputFormat:(LEInputFormat *)newFormat
{
    [_io writeInputFormat:newFormat forConnectID:_connectInfo.connectID];
}

- (LEInputFormat *)defaultInputFormat
{
    //Should be overwritten in sub-classes for known (non generic) IO types
    return nil;
}

- (void)addValidDataFormat:(LEDataFormat *)dataFormat
{
    NSParameterAssert(dataFormat);
    if (!self.validDataFormats) {
        self.validDataFormats = [NSSet setWithObject:dataFormat];
    } else {
        self.validDataFormats = [self.validDataFormats setByAddingObject:dataFormat];
    }
}

- (void)removeValidDataFormat:(LEDataFormat *)dataFormat
{
    NSParameterAssert(dataFormat);
    if (!self.validDataFormats) {
        return;
    }
    self.validDataFormats = [self.validDataFormats setByRemovingObject:dataFormat];
}

- (uint8_t)inputFormatMode
{
    if (self.inputFormat) {
        return self.inputFormat.mode;
    } else if (self.defaultInputFormat) {
        return self.defaultInputFormat.mode;
    }
    LEDebugLog(@"No inputFormat set, returning mode 0");
    return 0;
}

- (void)updateCurrentInputFormatWithNewMode:(uint8_t)newMode
{
    if (self.inputFormat) {
        [self updateInputFormat:[self.inputFormat inputFormatBySettingMode:newMode]];
    } else if (self.defaultInputFormat) {
        [self updateInputFormat:[self.defaultInputFormat inputFormatBySettingMode:newMode]];
    } else {
        LEErrorLog("Tried to update input format with new mode, but no current inputFormat og defaultInputFormat is set");
    }
}

#pragma mark - Input Value

- (void)sendReadValueRequest
{
    [_io readValueForConnectID:_connectInfo.connectID];
}

- (void)sendResetStateRequest
{
    [_io resetStateForConnectID:_connectInfo.connectID];
}



#pragma mark - Format received data as numbers

- (NSUInteger)valueAsUnsignedInt
{
    if (self.valueData.length > sizeof(NSUInteger)) {
        return 0;
    }

    NSUInteger value = 0; //important that it is initialized to all zeroes
    [self.valueData getBytes:&value length:sizeof(value)];
    return value;
}

- (int32_t)valueAsInteger
{
    return [self integerFromData:self.valueData];
}

- (int32_t)integerFromData:(NSData *)data
{
    if (!data) {
        return 0;
    }

    if (data.length == sizeof(int8_t)) {
        int8_t value8;
        [data getBytes:&value8 length:sizeof(value8)];
        return value8;
    } else if (data.length == sizeof(int16_t)) {
        int16_t value16;
        [data getBytes:&value16 length:sizeof(value16)];
        return value16;
    } else if (data.length == sizeof(int32_t)) {
        int32_t value32;
        [data getBytes:&value32 length:sizeof(value32)];
        return value32;
    } else  {
        LEWarnLog(@"Cannot parse service value as singned int from data with size:", (unsigned long) data.length);
        return 0;
    }
}

- (Float32)valueAsFloat
{
    return [self floatFromData:self.valueData];
}

- (Float32)floatFromData:(NSData *)data{
    if (data.length > sizeof(Float32)) {
        return 0;
    }

    Float32 value = 0; //important that it is initialized to all zeroes
    [data getBytes:&value length:sizeof(value)];

    return value;
}

- (NSNumber *)numberFromValueData
{
    return [self numberFromValueData:self.valueData];
}

- (NSArray *)numbersFromValueDataSet
{
    return [self numbersFromValueDataSet:self.valueData];
}

- (NSNumber *)numberFromValueData:(NSData *)valueData
{
    NSArray *valuesAsNumbers = [self numbersFromValueDataSet:valueData];
    if (!valuesAsNumbers) {
        return nil;
    }
    
    if (valuesAsNumbers.count != 1) {
        LEWarnLog(@"Cannot get value from service %@ as as a number, the active data format is %@", self.serviceName, [self dataFormatForInputFormat:self.inputFormat]);
        return nil;
    }
    
    return valuesAsNumbers.firstObject;
}

- (NSArray *)numbersFromValueDataSet:(NSData *)dataSet
{
    if (!dataSet) {
        return nil;
    }

    LEDataFormat *dataFormat = [self dataFormatForInputFormat:self.inputFormat];
    if (!dataFormat) {
        return nil;
    }

    if (![self verifyData:dataSet correspondsToDataFormat:dataFormat error:NULL]) {
        return nil;
    }

    NSMutableArray *results = [NSMutableArray arrayWithCapacity:dataFormat.dataSetCount];
    for (int i = 0; i < dataFormat.dataSetCount; ++i) {
        NSData *dataSetBytes = [dataSet subdataWithRange:NSMakeRange(i * dataFormat.dataSetSize, dataFormat.dataSetSize)];
        if (dataFormat.unit == LEInputFormatUnitRaw || dataFormat.unit == LEInputFormatUnitPercentage) {
            [results addObject:@([self integerFromData:dataSetBytes])];
        } else {
            [results addObject:@([self floatFromData:dataSetBytes])];
        }
    }

    return results;
}


#pragma mark - Output

- (void)writeData:(NSData *)data
{
    [self.io writeData:data connectID:self.inputFormat.connectID];
}


#pragma mark - LEIODelegate

- (void)io:(LEIO *)io didReceiveInputFormat:(LEInputFormat *)inputFormat
{
    if (![inputFormat isEqual:self.inputFormat]) {
        [self handleUpdatedInputFormat:inputFormat];
    }
}

//May be overwritten in sub-classes
- (void)handleUpdatedInputFormat:(LEInputFormat *)inputFormat
{
    LEInputFormat *oldFormat = self.inputFormat;
    self.inputFormat = inputFormat;

    [self.delegates foreachPerform:@selector(service:didUpdateInputFormatFrom:to:) withObject:self withObject:oldFormat withObject:inputFormat];

    //After having received a new input format, we want the newest update value according to that format
    [self sendReadValueRequest];
}

- (void)io:(LEIO *)io didReceiveValueData:(NSData *)valueData
{
    if (![self.valueData isEqualToData:valueData]) {
        NSError *error;
        [self handleUpdatedValueData:valueData error:&error];
        if (error) {
            LEErrorLog(@"%@", error.localizedDescription);
        }
    }
}

//May be overwritten in sub-classes
- (BOOL)handleUpdatedValueData:(NSData *)valueData error:(NSError **)error
{
    BOOL dataDidVerify = [self verifyData:valueData error:error];
    if (dataDidVerify) {
        NSData *oldData = self.valueData;
        self.valueData = valueData;

        [self.delegates foreachPerform:@selector(service:didUpdateValueDataFrom:to:) withObject:self withObject:oldData withObject:valueData];
    }
    return dataDidVerify;
}

- (LEConnectInfo *)ioDidRequestConnectInfo:(LEIO *)io
{
    return self.connectInfo;
}


#pragma mark - Verify Data

- (BOOL)verifyData:(NSData *)data error:(NSError **)error
{
    if (!data) {
        //No data is always ok
        return YES;
    }

    if (self.validDataFormats.count == 0) {
        //If no LEInputDataFormats are defined all received data is accepted
        return YES;
    }

    //If one or more LEInputDataFormats are defined, we look at the latest received LEInputFormat from the device
    //For a received value to be accepted, there:
    //1. Must exist an LEDataFormat that matches the latest received LEInputFormat from device
    //2. The received valueData length must match this LEDataFormat
    LEDataFormat *dataFormat = [self dataFormatForInputFormat:self.inputFormat];
    if (!dataFormat) {
        NSString *msg = [NSString stringWithFormat:@"Did not find an valid input data format. \nThe input format recieved from device is: %@ \nSupported formats: %@", self.inputFormat.description, self.validDataFormats];
        if (error) {
            *error = [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeInternalError userInfo:@{ NSLocalizedDescriptionKey : msg }];
        }
        return NO;
    }

    return [self verifyData:data correspondsToDataFormat:dataFormat error:error];
}

- (BOOL)verifyData:(NSData *)data correspondsToDataFormat:(LEDataFormat *)format error:(NSError **)error
{
    BOOL didVerify = (data.length == (format.dataSetSize * format.dataSetCount));
    if (!didVerify) {
        NSString *msg = [NSString stringWithFormat:@"Value for service %@ in mode %@ unit %@ is expected to have %i data sets each with size %i bytes, but did receive package with length %lu",
                                                   self.serviceName, format.modeName, format.unitName, format.dataSetCount, format.dataSetSize, (unsigned long)data.length];
        if (error) {
            *error = [NSError errorWithDomain:LEDeviceErrorDomain code:LEErrorCodeInternalError userInfo:@{ NSLocalizedDescriptionKey : msg }];
        }

    }
    return didVerify;
}

- (LEDataFormat *)dataFormatForInputFormat:(LEInputFormat *)inputFormat
{
    for (LEDataFormat *dataFormat in self.validDataFormats) {
        if (dataFormat.mode == inputFormat.mode && dataFormat.unit == inputFormat.unit) {
            if ((dataFormat.dataSetSize * dataFormat.dataSetCount) != inputFormat.numberOfBytes) {
                LEErrorLog(@"%@ in mode %@ (%@): expected data length is %i data sets of %i bytes input format received from device says %i number of bytes",
                                self.serviceName, dataFormat.modeName, dataFormat.unitName, dataFormat.dataSetCount, dataFormat.dataSetSize, inputFormat.numberOfBytes);
                return nil;
            }
            return dataFormat;
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

    return [self isEqualToService:other];
}

- (BOOL)isEqualToService:(LEService *)otherService
{
    if (self == otherService)
        return YES;
    if (otherService == nil)
        return NO;
    if (self.connectInfo != otherService.connectInfo && ![self.connectInfo isEqualToConnectInfo:otherService.connectInfo])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    return [self.connectInfo hash];
}

#pragma mark - KVO compliance

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
    if ([@[@"numberFromValueData", @"numbersFromValueDataSet", @"valueAsInteger", @"valueAsFloat"] containsObject:key]) {
        keyPaths = [keyPaths setByAddingObject:@"valueData"];
    }
    return keyPaths;
}


@end