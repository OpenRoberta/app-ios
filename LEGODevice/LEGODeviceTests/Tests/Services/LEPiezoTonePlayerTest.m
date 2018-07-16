//
//  LEPiezoTonePlayerTest.m
//  LEGODeviceDemo
//
//  Created by Søren Toft Odgaard on 19/05/14.
//  Copyright (c) 2014 Søren Toft Odgaard. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LETestCase.h"
#import "LEPiezoTonePlayer.h"
#import "LEService+Project.h"
#import "LEConnectInfo+Project.h"

@interface LEPiezoTonePlayerTest : LETestCase

@end

@implementation LEPiezoTonePlayerTest {
    LEConnectInfo *_connectInfo;
    id _ioMock;
    LEPiezoTonePlayer *_player;
}

- (void)setUp
{
    [super setUp];
    _connectInfo = [LEConnectInfo connectInfoWithConnectID:1 hubIndex:1 type:LEIOTypePiezoTone];
    _ioMock = [OCMockObject mockForClass:[LEIO class]];
    [[_ioMock expect] addDelegate:[OCMArg any]];
    _player = [[LEPiezoTonePlayer alloc] initWithConnectInfo:_connectInfo io:_ioMock];

}


- (void)testPlayPiezoTone
{
    NSUInteger frequency = 440;
    NSUInteger duration = 1000;

    //Setup methods expected to be invoked on mock
    [[_ioMock expect] writePiezoToneFrequency:(uint16_t) frequency milliseconds:(uint16_t) duration connectID:_connectInfo.connectID];

    //Execute MUT
    [_player playFrequency:frequency forMilliseconds:duration];

    //Verify
    [_ioMock verify];
}

- (void)testPlayPiezoNote
{
    [self verifyNote:LEPiezoTonePlayerNoteA octave:4 translatesToFrequency:440];
    [self verifyNote:LEPiezoTonePlayerNoteB octave:4 translatesToFrequency:494];
    [self verifyNote:LEPiezoTonePlayerNoteA octave:5 translatesToFrequency:880];
}

- (void)testPlayPiezoNote_highest_supported_note {
    [self verifyNote:LEPiezoTonePlayerNoteFis octave:6 translatesToFrequency:1480];
}

- (void)testPlayPiezoNote_higher_than_supported_is_rounded_down_to_max {
    [self verifyNote:LEPiezoTonePlayerNoteG octave:6 translatesToFrequency:1500];
}

- (void)testPlayPiezoNote_higher_octave_than_supported_is_rounded_down_to_max {
    [self verifyNote:LEPiezoTonePlayerNoteG octave:7 translatesToFrequency:1500];
}

- (void)testPlayPiezoNote_lowest_supported_note {
    [self verifyNote:LEPiezoTonePlayerNoteC octave:0 translatesToFrequency:16];
}

- (void)verifyNote:(LEPiezoTonePlayerNote)note octave:(NSUInteger)octave translatesToFrequency:(NSUInteger)frequency {
    NSUInteger duration = 0;

    //Setup methods expected to be invoked on mock
    [[_ioMock expect] writePiezoToneFrequency:(uint16_t) frequency milliseconds:(uint16_t) duration connectID:_connectInfo.connectID];

    //Execute MUT
    [_player playNote:note octave:octave forMilliSeconds:duration];

    //Verify
    [_ioMock verify];

}


- (void)testStopPiezoTone
{
    //Setup methods expected to be invoked on mock
    [[_ioMock expect] writePiezoToneStopForConnectID:_connectInfo.connectID];

        //Execute MUT
    [_player stopPlaying];

    //Verify
    [_ioMock verify];
}


@end
