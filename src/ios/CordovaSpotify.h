#ifndef CordovaSpotify_h
#define CordovaSpotify_h

#import <Cordova/CDVPlugin.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SafariServices/SafariServices.h>
#import <AVFoundation/AVFoundation.h>

#import "AudioStreamingDelegate.h"
#import "AudioStreamingPlaybackDelegate.h"

@interface CordovaSpotify : CDVPlugin
    @property (nonatomic) bool isLoggedIn;
    @property (nonatomic) AudioStreamingDelegate *audioStreamingDelegate;
    @property (nonatomic) AudioStreamingPlaybackDelegate *audioStreamingPlaybackDelegate;
    @property (nonatomic, strong) SPTAudioStreamingController* player;

    - (void) pluginInitialize;

    - (void) authenticate:(CDVInvokedUrlCommand*)command;
    - (void) login:(CDVInvokedUrlCommand*)command;
    - (void) play:(CDVInvokedUrlCommand*)command;
    - (void) pause:(CDVInvokedUrlCommand*)command;
    - (void) registerEventsListener:(CDVInvokedUrlCommand*)command;

    - (void) initSession:(SPTSession*)session withClientId:(NSString*)clientId andError:(NSError*)err andCommand:(CDVInvokedUrlCommand*)command;
    - (void) sendResultForCommand:(CDVInvokedUrlCommand*)cmd withError:(NSError*)err andSuccess:(NSString*)success;
@end

#endif
