#ifndef CordovaSpotify_h
#define CordovaSpotify_h

#import <Cordova/CDVPlugin.h>
#import <SpotifyAudioPlayback/SpotifyAudioPlayback.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SafariServices/SafariServices.h>

@interface CordovaSpotify : CDVPlugin <SPTAudioStreamingDelegate>

@property (nonatomic) bool isLoggedIn;
@property (nonatomic, strong) SPTSession* session;
@property (nonatomic, strong) SPTAudioStreamingController* player;

- (void) pluginInitialize;

- (void) authenticate:(CDVInvokedUrlCommand*)command;
- (void) play:(CDVInvokedUrlCommand*)command;

- (void) sendResultForCommand:(CDVInvokedUrlCommand*)cmd withError:(NSError*)err andSuccess:(NSString*)success;
@end

#endif /* CordovaSpotify_h */
