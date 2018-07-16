//
// Created by Søren Toft Odgaard on 19/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import "LEPiezoTonePlayer.h"
#import "LEService+Project.h"
#import "LELogger+Project.h"


@implementation LEPiezoTonePlayer

- (NSString *)serviceName
{
    return @"Piezo";
}

- (void)playFrequency:(NSUInteger)frequency forMilliseconds:(NSUInteger)ms
{
    if (frequency > LEPiezoToneMaxFrequency) {
        LEWarnLog(@"Cannot play frequenzy %lu, max supported frequency is %lu", (unsigned long) frequency, LEPiezoToneMaxFrequency);
        frequency = LEPiezoToneMaxFrequency;
    }
    if (ms > LEPiezoToneMaxDuration) {
        LEWarnLog(@"Cannot play piezo tone with duration %lu ms, max supported frequency is %lu ms", (unsigned long) ms, LEPiezoToneMaxDuration);
        ms = LEPiezoToneMaxDuration;
    }

    [self.io writePiezoToneFrequency:(uint16_t) frequency milliseconds:(uint16_t) ms connectID:self.connectInfo.connectID];
}

- (void)playNote:(LEPiezoTonePlayerNote)note octave:(NSUInteger)octave forMilliSeconds:(NSUInteger)ms
{
    if (octave > 6) {
        LEWarnLog(@"Highest supported note is F# in 6th octave - invalid octave: %lu", (unsigned long) octave);
    }
    if (octave == 6 && note > LEPiezoTonePlayerNoteFis) {
        LEWarnLog(@"Cannot play note. Highest supported note is F# in 6th octave");
    }

    /**
    The basic formula for the frequencies of the notes of the equal tempered scale is given by
    fn = f0 * (a)n
    where
    f0 = the frequency of one fixed note which must be defined. A common choice is setting the A above middle C (A4) at f0 = 440 Hz.
    n = the number of half steps away from the fixed note you are. If you are at a higher note, n is positive. If you are on a lower note, n is negative.
    fn = the frequency of the note n half steps away.
    a = (2)1/12 = the twelfth root of 2 = the number which when multiplied by itself 12 times equals 2 = 1.059463094359...
    */

    double base = 440.0;
    NSInteger octavesAboveMiddle = octave - 4;
    CGFloat halfStepsAwayFromBase = (CGFloat) note - (CGFloat) LEPiezoTonePlayerNoteA + (octavesAboveMiddle * 12);
    double frequency = base * pow(pow(2.0, 1.0 / 12), halfStepsAwayFromBase);

    [self playFrequency:(NSUInteger) (round(frequency)) forMilliseconds:ms];
}

- (void)stopPlaying
{
    [self.io writePiezoToneStopForConnectID:self.connectInfo.connectID];
}


@end