//
// Created by Marcus Weiner on 27.12.16.
// Copyright (c) 2016 Festify. All rights reserved.
//

#import "AudioStreamingPlaybackDelegate.h"


@implementation AudioStreamingPlaybackDelegate

- (instancetype)initWithCommandDelegate:(id <CDVCommandDelegate>)commandDelegate {
    self = [super initWithCommandDelegate: commandDelegate];

    if(self) {
        self.codeMatrix = @{
            [NSNumber numberWithInteger:SPPlaybackNotifyPlay]: @"Play",
            [NSNumber numberWithInteger:SPPlaybackNotifyPause]: @"Pause",
            [NSNumber numberWithInteger:SPPlaybackNotifyTrackChanged]: @"TrackChanged",
            [NSNumber numberWithInteger:SPPlaybackNotifyNext]: @"Next",
            [NSNumber numberWithInteger:SPPlaybackNotifyPrev]: @"Prev",
            [NSNumber numberWithInteger:SPPlaybackNotifyShuffleOn]: @"ShuffleOn",
            [NSNumber numberWithInteger:SPPlaybackNotifyShuffleOff]: @"ShuffleOff",
            [NSNumber numberWithInteger:SPPlaybackNotifyRepeatOn]: @"RepeatOn",
            [NSNumber numberWithInteger:SPPlaybackNotifyRepeatOff]: @"RepeatOff",
            [NSNumber numberWithInteger:SPPlaybackNotifyBecameActive]: @"BecameActive",
            [NSNumber numberWithInteger:SPPlaybackNotifyBecameInactive]: @"BecameInactive",
            [NSNumber numberWithInteger:SPPlaybackNotifyLostPermission]: @"LostPermission",
            [NSNumber numberWithInteger:SPPlaybackEventAudioFlush]: @"AudioFlush",
            [NSNumber numberWithInteger:SPPlaybackNotifyAudioDeliveryDone]: @"AudioDeliveryDone",
            [NSNumber numberWithInteger:SPPlaybackNotifyContextChanged]: @"ContextChanged",
            [NSNumber numberWithInteger:SPPlaybackNotifyTrackDelivered]: @"TrackDelivered",
            [NSNumber numberWithInteger:SPPlaybackNotifyMetadataChanged]: @"MetadataChanged",
        };
    }

    return self;
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceivePlaybackEvent:(SpPlaybackEvent)event {
    [self emit:@"playbackevent" withData:@[getErrorFromMatrix(self.codeMatrix, [NSNumber numberWithInteger: event])]];
}

@end