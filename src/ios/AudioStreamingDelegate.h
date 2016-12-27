#ifndef AudioStreamingDelegate_h
#define AudioStreamingDelegate_h

#import <SpotifyAudioPlayback/SPTAudioStreamingController.h>
#import <SpotifyAudioPlayback/SPTAudioStreamingController_ErrorCodes.h>
#import "CordovaEventEmitter.h"

@interface AudioStreamingDelegate : CordovaEventEmitter <SPTAudioStreamingDelegate>
@end
#endif