#ifndef AudioStreamingPlaybackDelegate_h
#define AudioStreamingPlaybackDelegate_h

#import <SpotifyAudioPlayback/SPTAudioStreamingController.h>
#import "CordovaSpotifyEventEmitter.h"

@interface AudioStreamingPlaybackDelegate : CordovaSpotifyEventEmitter <SPTAudioStreamingPlaybackDelegate>
@end

#endif