#ifndef AudioStreamingPlaybackDelegate_h
#define AudioStreamingPlaybackDelegate_h

#import <SpotifyAudioPlayback/SPTAudioStreamingController.h>
#import "CordovaEventEmitter.h"

@interface AudioStreamingPlaybackDelegate : CordovaEventEmitter <SPTAudioStreamingPlaybackDelegate>
@end

#endif