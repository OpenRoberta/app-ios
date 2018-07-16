//
//  UnityInvoker.h
//  LEGODevice
//
//  Created by Bartlomiej Hyzy on 31/03/2015.
//  Copyright (c) 2015 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LEGOUnityInvoker : NSObject

+ (void)invokeMethod:(NSString *)unityMethodName withData:(NSDictionary *)dataDictionary;

@end
