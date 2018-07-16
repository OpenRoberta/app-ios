//
//  MultiDelegate.m
//  LEGODevice
//
//  Created by Jon Nørrelykke on 02/12/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import "LEMultiDelegate.h"
#import "LELogger+Project.h"
#import "LERevision.h"

@interface ObjectProxy : NSObject
@property (nonatomic, weak) id object;
+ (ObjectProxy*)proxyWithObject:(id)object;
@end

@implementation ObjectProxy

+ (ObjectProxy *)proxyWithObject:(id)object {
    if ([object isKindOfClass:ObjectProxy.class]) return object;
    
    ObjectProxy *op = [ObjectProxy new];
    op.object = object;
    return  op;
}

- (BOOL)isEqual:(id)other {
    if (!other) return NO;
    if (other == self) return YES;
    if (![other isKindOfClass:ObjectProxy.class]) return NO;
    ObjectProxy *otherProxy = (ObjectProxy*)other;
    return [self.object isEqual:otherProxy.object];
}

- (NSUInteger)hash
{
    //Inefficient hash implementation, yes!
    //But by calling self.object.hash I have not been able to make the unit tests pass...not sure why
    //Not overwriting hash is not an option when overwriting equals...this will also cause the tests to fail.
    return 0;
}


@end


@implementation LEMultiDelegate {
    NSMutableSet *_set;
}

+ (instancetype)multiDelegate
{
    return [[LEMultiDelegate alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
        _set = [NSMutableSet new];
    }
    return self;
}

#pragma mark - Public methods

- (void)addDelegate:(id)object {
    if (!object) return;
    [self cleanUp];
    [_set addObject:[ObjectProxy proxyWithObject:object]];
}

- (void)removeDelegate:(id)object {
    //Be careful not to create a reference (weak or strong) to object
    //here, as object may be deallocating - it will cause a crash
    ObjectProxy *proxyToRemove = [self proxyForObject:object];
    if (proxyToRemove) {
        [_set removeObject:proxyToRemove];
    }
}

- (ObjectProxy *)proxyForObject:(id)object
{
    if (object == nil) return nil;
    ObjectProxy *theProxy;
    for (ObjectProxy *aProxy in _set) {
        if (aProxy.object == object) {
            theProxy = aProxy;
            break;
        }
    }
    return theProxy;
}

- (NSUInteger)count {
    return [_set count];
}

- (void)foreach:(void (^)(id delegate, BOOL *stop))block {
    [_set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        ObjectProxy *proxy = obj;
        block(proxy.object, stop);
    }];
}

- (void)foreachPerform:(SEL)selector withObject:(id)parameter {
    [self foreachPerform:selector withObject:parameter withObject:nil withObject:nil withObject:nil];
}

- (void)foreachPerform:(SEL)selector withObject:(id)parameter1 withObject:(id)parameter2 {
    [self foreachPerform:selector withObject:parameter1 withObject:parameter2 withObject:nil withObject:nil];
}

-(void)foreachPerform:(SEL)selector withObject:(id)parameter1 withObject:(id)parameter2 withObject:(id)parameter3 {
    [self foreachPerform:selector withObject:parameter1 withObject:parameter2 withObject:parameter3 withObject:nil];
}

- (void)foreachPerform:(SEL)selector withObject:(id)parameter1 withObject:(id)parameter2 withObject:(id)parameter3 withObject:(id)parameter4   {
    [_set enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        ObjectProxy *proxy = obj;
        if ([proxy.object respondsToSelector:selector]) {
            NSUInteger numberOfArgs = [proxy.object methodSignatureForSelector:selector].numberOfArguments - 2;

            switch (numberOfArgs) {
                case 0:
                    ((void (*)(id, SEL))[proxy.object methodForSelector:selector])(proxy.object, selector);
                    break;
                    
                case 1:
                    ((void (*)(id, SEL, id))[proxy.object methodForSelector:selector])(proxy.object, selector, parameter1);
                    break;
                    
                case 2:
                    ((void (*)(id, SEL, id, id))[proxy.object methodForSelector:selector])(proxy.object, selector, parameter1, parameter2);
                    break;
                    
                case 3:
                    ((void (*)(id, SEL, id, id, id))[proxy.object methodForSelector:selector])(proxy.object, selector, parameter1, parameter2, parameter3);
                    break;
                    
                case 4:
                    ((void (*)(id, SEL, id, id, id, id))[proxy.object methodForSelector:selector])(proxy.object, selector, parameter1, parameter2, parameter3, parameter4);
                    break;
                    
                default:
                    LEDebugLog(@"Selector %@ takes %lx arguments", NSStringFromSelector(selector), (long)numberOfArgs);
                    break;
            }
        }
    }];
}

#pragma mark - Private methods

- (void)cleanUp {
    NSMutableSet *toDelete = [NSMutableSet new];
    [_set enumerateObjectsUsingBlock:^(ObjectProxy *proxy, BOOL *stop) {
        if (proxy.object == nil) [toDelete addObject:proxy];
    }];
    for (ObjectProxy *proxy in toDelete) {
        LEDebugLog(@"Removing nil delegate");
        [_set removeObject:proxy];
    }
}

@end
