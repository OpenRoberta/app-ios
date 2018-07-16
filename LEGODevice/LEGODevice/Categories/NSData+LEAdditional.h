//
//  NSData+LEAdditional.h
//  LEGODevice
//
//  Created by Søren Toft Odgaard on 20/11/13.
//  Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (LEAdditional)

- (NSData *)dataByTrimmingAllBytesFromFirstZero;

- (void)enumerateInChuncksOfSize:(NSUInteger)chunckSize
                       withBlock:(void (^)(Byte *chunk, BOOL *stop))block;

- (NSData *)dataByAppendingData:(NSData *)data;





@end
