//
// Created by Søren Toft Odgaard on 02/12/14.
//

#import <Foundation/Foundation.h>

#define NSStringFromCString(cstring) [LEGOWrapperUtils createNSStringFromCString:cstring]
#define NSIntegerFromCString(cstring) ([LEGOWrapperUtils createNSStringFromCString:cstring].integerValue)
#define CStringFromNSString(nsstring) [LEGOWrapperUtils createCStringFromNSString:nsstring]

extern char *LEGOMakeStringCopy (const char* string);

@interface LEGOWrapperUtils : NSObject

+ (NSString *)createNSStringFromCString:(const char *)cString;
+ (const char *)createCStringFromNSString:(NSString const *)string;

@end
