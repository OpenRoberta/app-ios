//
// Created by Søren Toft Odgaard on 29/07/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LERevision.h"

@interface LERevision (Project)

+ (instancetype)revisionWithString:(NSString *)revisionString;

+ (instancetype)revisionWithData:(NSData *)revisionData;


@end