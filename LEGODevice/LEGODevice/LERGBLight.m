//
// Created by Søren Toft Odgaard on 20/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LERGBLight.h"
#import "LEService+Project.h"
#import "LEInputFormat.h"
#import "LELogger+Project.h"
#import "CIColor+LEAdditional.h"
#import "LEDataFormat.h"
#import "LEDevice.h"

@interface LERGBLight ()

@property (nonatomic, readwrite) uint8_t absoluteModeIndex;
@property (nonatomic, readwrite) uint8_t discreteModeIndex;

@end

@implementation LERGBLight

- (NSString *)serviceName
{
    return @"RGB Light";
}

- (LEInputFormat *)defaultInputFormat
{
    return [LEInputFormat
            inputFormatWithConnectID:self.connectInfo.connectID
            typeID:self.connectInfo.type
            mode:0
            deltaInterval:1
            unit:LEInputFormatUnitRaw
            notificationsEnabled:YES];
}

- (void)setDevice:(LEDevice *)device {
    [super setDevice:device];
    
    if (self.device.deviceInfo.firmwareRevision.majorVersion == 0) {
        self.absoluteModeIndex = 0;
        self.discreteModeIndex = 1; //not supported on firmware version 0
    } else {
        self.absoluteModeIndex = 1;
        self.discreteModeIndex = 0;
    }
        
    [self addValidDataFormats];
}

- (void)addValidDataFormats
{
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Discrete" mode:self.discreteModeIndex unit:LEInputFormatUnitRaw sizeOfDataSet:sizeof(uint8_t) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Discrete" mode:self.discreteModeIndex unit:LEInputFormatUnitPercentage sizeOfDataSet:sizeof(uint8_t) dataSetCount:1]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Discrete" mode:self.discreteModeIndex unit:LEInputFormatUnitSI sizeOfDataSet:sizeof(Float32) dataSetCount:1]];
    
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Absolute" mode:self.absoluteModeIndex unit:LEInputFormatUnitRaw sizeOfDataSet:sizeof(uint8_t) dataSetCount:3]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Absolute" mode:self.absoluteModeIndex unit:LEInputFormatUnitPercentage sizeOfDataSet:sizeof(uint8_t) dataSetCount:3]];
    [self addValidDataFormat:[LEDataFormat formatWithModeName:@"Absolute" mode:self.absoluteModeIndex unit:LEInputFormatUnitSI sizeOfDataSet:sizeof(Float32) dataSetCount:3]];
    
}

- (BOOL)isAbsoluteMode
{
    return ([super inputFormatMode] == self.absoluteModeIndex);
}


- (BOOL)isDiscreteMode
{
    return ([super inputFormatMode] == self.discreteModeIndex);
    
}

- (void)setRgbMode:(uint8_t)rgbMode
{
    if ([self isOnlyAbsoluteModeSupported] && rgbMode != self.absoluteModeIndex) {
        LEWarnLog(@"Firmware only supports LERGBModeAbsolute");
    } else {
        [super updateCurrentInputFormatWithNewMode:rgbMode];
    }
}

- (uint8_t)rgbMode
{
    return [super inputFormatMode];
}

//Prior to version 1.0 of the firmware, there is only mode zero (absolute) supported
- (BOOL)isOnlyAbsoluteModeSupported
{
    return self.device.deviceInfo.firmwareRevision.majorVersion == 0;
}


- (void)setColor:(CIColor *)color
{
    if (self.rgbMode == self.absoluteModeIndex) {
        _oldColor = _color;
        _color = color;
        
        uint8_t red = (uint8_t) round(255.0 * color.red);
        uint8_t green = (uint8_t) round(255.0 * color.green);
        uint8_t blue = (uint8_t) round(255.0 * color.blue);
        [self.io writeColorRed:red green:green blue:blue connectID:self.connectInfo.connectID];
    } else {
        LEWarnLog(@"Ingoring attempt to set RGB color. Is only supported when RGB is in mode Absolute");
    }
}


- (void)setColorIndex:(NSUInteger)colorIndex
{
    if (self.rgbMode == self.discreteModeIndex) {
        _oldColorIndex = _colorIndex;
        _colorIndex = colorIndex;
        
        [self.io writeColorIndex:colorIndex connectID:self.connectInfo.connectID];
    } else {
        LEWarnLog(@"Ingoring attempt to set RGB color index. Is only supported when RGB is in mode Discrete");
    }    
}


- (void)switchOff
{
    if (self.rgbMode == self.absoluteModeIndex) {
        [self setColor:[CIColor colorWithRed:0 green:0 blue:0]];
    } else if (self.rgbMode == self.discreteModeIndex) {
        [self setColorIndex:0];
    } else {
        LEWarnLog(@"Cannot swith off RGB - unknown mode: %i", self.rgbMode);
    }
}

- (void)switchToDefaultColor
{
    if (self.rgbMode == self.absoluteModeIndex) {
        [self setColor:self.defaultColor];
    } else if (self.rgbMode == self.discreteModeIndex) {
        [self setColorIndex:self.defaultColorIndex];
    } else {
        LEWarnLog(@"Cannot swith to default color - unknown mode: %i", self.rgbMode);
    }

}


- (BOOL)handleUpdatedValueData:(NSData *)valueData error:(NSError **)error
{
    if (self.rgbMode == self.absoluteModeIndex) {
        [self willChangeValueForKey:@"color"];
        
        BOOL success = [super handleUpdatedValueData:valueData error:error];
        
        // We need to handle the case where the color has been updated "behind the back"
        CIColor *newColor = [self colorWithData:valueData];
        
        if (newColor != _color)
        {
            _oldColor = _color;
        }
        _color = newColor;

        [self didChangeValueForKey:@"color"];

        if (success) {
            __weak __typeof__(self) weakSelf = self;
            [self.delegates foreach:^(id delegate, BOOL *stop) {
                if ([delegate respondsToSelector:@selector(rgbLight:didUpdateColorFrom:to:)]) {
                    [delegate rgbLight:weakSelf didUpdateColorFrom:_oldColor to:self.color];
                }
            }];
        }

        return success;
    } else if (self.rgbMode == self.discreteModeIndex) {
        [self willChangeValueForKey:@"colorIndex"];

        BOOL success = [super handleUpdatedValueData:valueData error:error];
        
        // We need to handle the case where the color has been updated "behind the back"
        NSInteger newColorIndex = (NSUInteger) [self numberFromValueData].intValue;
        
        if (newColorIndex != _colorIndex)
        {
            _oldColorIndex = _colorIndex;
        }
        _colorIndex = newColorIndex;

        //Looks like the Hub does not send a default color index, so we do not try to set that
        [self didChangeValueForKey:@"colorIndex"];

        if (success) {
            __weak __typeof__(self) weakSelf = self;
            [self.delegates foreach:^(id delegate, BOOL *stop) {
                if ([delegate respondsToSelector:@selector(rgbLight:didUpdateColorIndexFrom:to:)]) {
                    [delegate rgbLight:weakSelf didUpdateColorIndexFrom:_oldColorIndex to:self.colorIndex];
                }
            }];
        }

        return success;
    } else {
        LEErrorLog(@"Cannot handle response for RGB in unknown mode %i", self.rgbMode);
        return NO;
    }
}

- (CIColor *)defaultColor
{
    //We have no reliable way of reading the default color of the Hub, so it is hardcoded here
    return [LERGBLight colorWithHexRed:0x00 green:0x00 blue:0xFF];
}

- (NSUInteger)defaultColorIndex
{
    //We have no reliable way of reading the default color of the Hub, so it is hardcoded here
    return 3;
}


+ (CIColor *)colorWithHexRed:(Byte)r green:(Byte)g blue:(Byte)b
{
    return [CIColor colorWithRed:(CGFloat) (r / 255.0) green:(CGFloat) (g / 255.0) blue:(CGFloat) (b / 255.0) alpha:1.0];
}

- (CIColor *)colorWithData:(NSData *)data
{
    if (self.rgbMode == self.absoluteModeIndex) {
        NSArray *values = [self numbersFromValueDataSet:data];
        uint8_t red = (uint8_t) ((NSNumber *) values[0]).intValue;
        uint8_t green = (uint8_t) ((NSNumber *) values[1]).intValue;
        uint8_t blue = (uint8_t) ((NSNumber *) values[2]).intValue;
        return [CIColor colorWithIntRed:red green:green blue:blue];
    }

    LEErrorLog(@"Cannot create color from data %@", data);
    return nil;
}

+ (NSSet *)keyPathsForValuesAffectingRgbMode
{
    return [NSSet setWithObjects:@"inputFormat", @"defaultInputFormat", nil];
}

@end