#ifndef AudioStreamingDelegate_h
#define AudioStreamingDelegate_h

#import <SpotifyAudioPlayback/SPTAudioStreamingController.h>
#import "CordovaEventEmitter.h"

@interface AudioStreamingDelegate : CordovaEventEmitter <SPTAudioStreamingDelegate>
@end
#endif