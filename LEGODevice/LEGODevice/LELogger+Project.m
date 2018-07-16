//
// Created by Søren Toft Odgaard on 10/04/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LELogger+Project.h"

@implementation LELogger (Project)

- (void)log:(NSString *)format args:(va_list)args level:(LELoggerLevel)level
{
    if (level < self.logLevel) return;

    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];

    //Write the message to log (the writer may have been provided by the calling App)
    if (self.logWriter) {
        [self.logWriter writeMessage:message logLevel:level];
    } else {
        NSLog(message, nil);
    }
}

@end

void LELog(LELoggerLevel level, NSString *format, ...)
{
    va_list args;
    va_start(args, format);
    [[LELogger defaultLogger] log:format args:args level:level];
    va_end(args);
}
