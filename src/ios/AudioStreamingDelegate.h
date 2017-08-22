#ifndef AudioStreamingDelegate_h
#define AudioStreamingDelegate_h

#import <SpotifyAudioPlayback/SPTAudioStreamingController.h>
#import <SpotifyAudioPlayback/SPTAudioStreamingController_ErrorCodes.h>
#import "CordovaSpotifyEventEmitter.h"

@interface AudioStreamingDelegate : CordovaSpotifyEventEmitter <SPTAudioStreamingDelegate>
    @property (nonatomic, copy) void (^loginCallback)(NSError*);
    @property (nonatomic, copy) void (^logoutCallback)(void);

    - (void) handleLoginWithCallback: (void (^)(NSError*))callback;
    - (void) handleLogoutWithCallback: (void (^)(void))callback;
@end

#endif
