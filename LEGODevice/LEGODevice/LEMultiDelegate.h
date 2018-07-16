//
//  MultiDelegate.h
//  LEGODevice
//
//  Created by Jon Nørrelykke on 02/12/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEMultiDelegate : NSObject

+ (instancetype)multiDelegate;

- (void)addDelegate:(id)object;
- (void)removeDelegate:(id)object;
- (NSUInteger)count;

- (void)foreach:(void (^)(id delegate, BOOL *stop))block;
- (void)foreachPerform:(SEL)selector withObject:(id)parameter;
- (void)foreachPerform:(SEL)selector withObject:(id)parameter1 withObject:(id)parameter2;
- (void)foreachPerform:(SEL)selector withObject:(id)parameter1 withObject:(id)parameter2 withObject:(id)parameter3;
- (void)foreachPerform:(SEL)selector withObject:(id)parameter1 withObject:(id)parameter2 withObject:(id)parameter3 withObject:(id)parameter4;

@end
