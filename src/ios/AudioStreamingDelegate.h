#ifndef AudioStreamingDelegate_h
#define AudioStreamingDelegate_h

#import <SpotifyAudioPlayback/SPTAudioStreamingController.h>
#import <SpotifyAudioPlayback/SPTAudioStreamingController_ErrorCodes.h>
#import "CordovaSpotifyEventEmitter.h"

@interface AudioStreamingDelegate : CordovaSpotifyEventEmitter <SPTAudioStreamingDelegate>
@end

#endif