//
// Created by Søren Toft Odgaard on 22/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "CIColor+LEAdditional.h"


@implementation CIColor (LEAdditional)

+ (CIColor *)colorWithIntRed:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue
{
    return  [CIColor colorWithRed:(CGFloat) (red / 255.0) green:(CGFloat) (green / 255.0) blue:(CGFloat) (blue / 255.0)];
}


@end