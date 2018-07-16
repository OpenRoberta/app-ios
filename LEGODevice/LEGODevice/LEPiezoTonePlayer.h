//
// Created by Søren Toft Odgaard on 19/05/14.
// Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEService.h"

static const NSUInteger LEPiezoToneMaxFrequency = 1500;
static const NSUInteger LEPiezoToneMaxDuration = 65536;

/**
  Notes that can be played using the LEPiezoTonePlayer
*/
typedef NS_ENUM(NSUInteger, LEPiezoTonePlayerNote) {
    /** C */
    LEPiezoTonePlayerNoteC = 1,
    /** C# */
    LEPiezoTonePlayerNoteCis = 2,
    /** D */
    LEPiezoTonePlayerNoteD = 3,
    /** D# */
    LEPiezoTonePlayerNoteDis = 4,
    /** E */
    LEPiezoTonePlayerNoteE = 5,
    /** F */
    LEPiezoTonePlayerNoteF = 6,
    /** F# */
    LEPiezoTonePlayerNoteFis = 7,
    /** G */
    LEPiezoTonePlayerNoteG = 8,
    /** G# */
    LEPiezoTonePlayerNoteGis = 9,
    /** A */
    LEPiezoTonePlayerNoteA = 10,
    /** A# */
    LEPiezoTonePlayerNoteAis = 11,
    /** B */
    LEPiezoTonePlayerNoteB = 12,
};


/**
 This service allows for playing of tones at a given frequency
*/
@interface LEPiezoTonePlayer : LEService

/**
 Play a frequency for the given duration in ms
 @param frequency   The frequency to play (max allowed frequency is 1500)
 @param ms          The duration to play (max supported is 65536 milliseconds).
*/
- (void)playFrequency:(NSUInteger)frequency forMilliseconds:(NSUInteger)ms;

/**
 Play a note.
 The highest supported note is F# in 6th octave
 @param note    The note to play
 @param octave  The octave in which to play the note
 @param ms      The duration to play (max supported is 65536 milliseconds).
*/
- (void)playNote:(LEPiezoTonePlayerNote)note octave:(NSUInteger)octave forMilliSeconds:(NSUInteger)ms;

/**
 Stop playing any currently playing tone.
*/
- (void)stopPlaying;

@end