#ifndef CordovaSpotify_h
#define CordovaSpotify_h

#import <AVFoundation/AVFoundation.h>
#import <Cordova/CDVPlugin.h>
#import <SafariServices/SafariServices.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>

#import "AudioStreamingDelegate.h"
#import "AudioStreamingPlaybackDelegate.h"

@interface CordovaSpotify : CDVPlugin
    @property (nonatomic) NSString *currentClientId;
    @property (nonatomic) NSString *currentToken;
    @property (nonatomic) AudioStreamingDelegate *audioStreamingDelegate;
    @property (nonatomic) AudioStreamingPlaybackDelegate *audioStreamingPlaybackDelegate;
    @property (nonatomic, strong) SPTAudioStreamingController* player;
    @property (nonatomic, strong) SPTDiskCache* cache;

    - (void) pluginInitialize;

    - (void) play:(CDVInvokedUrlCommand*)command;
    - (void) pause:(CDVInvokedUrlCommand*)command;
    - (void) resume:(CDVInvokedUrlCommand*)command;
    - (void) registerEventsListener:(CDVInvokedUrlCommand*)command;

    - (void) doPlay:(NSString*)trackUri 
            fromPos:(NSInteger)positionMs 
        withCommand:(CDVInvokedUrlCommand*)command;
    - (void) initAndPlay:(NSString*)clientId
               withToken:(NSString*)accessToken 
                 withUri:(NSString*)trackUri 
                 fromPos:(NSInteger)positionMs 
             withCommand:(CDVInvokedUrlCommand*)command;
    - (void) loginAndPlay:(NSString*)accessToken 
                  withUri:(NSString*)trackUri 
                  fromPos:(NSInteger)positionMs 
              withCommand:(CDVInvokedUrlCommand*)command;
    - (void) logout:(void (^)(void))callback;
    - (void) sendResultForCommand:(CDVInvokedUrlCommand*)cmd 
                    withErrorType:(NSString*)err 
                         andDescr:(NSString*)errDescription
                       andSuccess:(NSString*)success;
@end

#endif
