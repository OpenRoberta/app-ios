//
// Created by Søren Toft Odgaard on 02/12/14.
//

#import "LEGOWrapperUtils.h"

@implementation LEGOWrapperUtils

+ (NSString *)createNSStringFromCString:(const char *)cString
{
    return [[[NSString alloc] initWithUTF8String:cString] autorelease];
}

+ (const char *)createCStringFromNSString:(NSString const *)string
{
    return [string cStringUsingEncoding:NSUTF8StringEncoding];
}

@end

char *LEGOMakeStringCopy (const char* string)
{
    if (string == NULL)
        return NULL;
    
    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}
