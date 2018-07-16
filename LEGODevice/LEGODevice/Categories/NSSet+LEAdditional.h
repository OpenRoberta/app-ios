//
// Created by Søren Toft Odgaard on 9/9/13.
// Copyright (c) 2013 Søren Toft Odgaard. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>

@interface NSSet (LEAdditional)

- (NSSet *)setByRemovingObject:(id)object;

- (NSArray *)filteredArrayWithKindOfClass:(Class)class sortedByProperty:(NSString *)propertyName ascending:(BOOL)ascending;

@end