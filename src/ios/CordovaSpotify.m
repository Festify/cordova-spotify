#import "CordovaSpotify.h"
#import <Foundation/Foundation.h>

@implementation CordovaSpotify

- (void)pluginInitialize {
    [SPTAuth defaultInstance].sessionUserDefaultsKey = @"CordovaSpotifySession";

    // Tell iOS to play audio even in background and when the ringer is silent
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];

    // Initialize delegates for event handling
    __weak id <CDVCommandDelegate> _commandDelegate = self.commandDelegate;
    self.audioStreamingDelegate = [AudioStreamingDelegate eventEmitterWithCommandDelegate: _commandDelegate];
    self.audioStreamingPlaybackDelegate = [AudioStreamingPlaybackDelegate eventEmitterWithCommandDelegate: _commandDelegate];

    self.player = [SPTAudioStreamingController sharedInstance];
    self.player.delegate = self.audioStreamingDelegate;
    self.player.playbackDelegate = self.audioStreamingPlaybackDelegate;
}

- (void) getPosition:(CDVInvokedUrlCommand*)command {
    double durationMs = [[self.player playbackState] position] * 1000.0;

    CDVPluginResult *result = [CDVPluginResult
            resultWithStatus: CDVCommandStatus_OK
             messageAsDouble: durationMs];

    [self.commandDelegate sendPluginResult: result callbackId: command.callbackId];
}

- (void) playTrack:(NSString*)trackUri fromPos:(NSInteger)positionMs withCommand:(CDVInvokedUrlCommand*)command {
    // Take over audio session
    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (!success) {
        if (activationError) {
            [self sendResultForCommand: command withError: activationError andSuccess: nil];
        } else {
            [self sendResultForCommand: command
                             withError: [NSError errorWithDomain:@"AudioSession" code:-1 userInfo:@{
                                 NSLocalizedDescriptionKey: @"Audio session could not be activated"
                             }]
                             andSuccess: nil];
        }
        return;
    }

    SPTErrorableOperationCallback cb = ^(NSError* err) {
        [self sendResultForCommand: command withError: err andSuccess: nil];
    };

    [self.player playSpotifyURI: trackUri 
              startingWithIndex: 0 
           startingWithPosition: positionMs / 1000.0 
                       callback: cb];
}

- (void) play:(CDVInvokedUrlCommand*)command {
    __weak CordovaSpotify* _self = self;

    NSString* trackUri = [command.arguments objectAtIndex: 0];
    NSString* accessToken = [command.arguments objectAtIndex: 1];
    NSInteger from = [[command.arguments objectAtIndex: 3] intValue];

    if(!self.player.loggedIn || ![accessToken isEqualToString: self.currentToken]) {
        [self.audioStreamingDelegate handleLoginWithCallback: ^(void) {
            [_self playTrack: trackUri fromPos: from withCommand: command];
        }];
        [self.player loginWithAccessToken: accessToken];
    }else{
        [self playTrack: trackUri fromPos: from withCommand: command];
    }
}

- (void) pause:(CDVInvokedUrlCommand*)command {
    __weak CordovaSpotify* _self = self;

    [self.player setIsPlaying: NO callback: ^(NSError* err) {
        [_self sendResultForCommand: command withError: err andSuccess: nil];
    }];
}

- (void) resume:(CDVInvokedUrlCommand*)command {
    __weak CordovaSpotify* _self = self;

    [self.player setIsPlaying: YES callback: ^(NSError* err) {
        [_self sendResultForCommand: command withError: err andSuccess: nil];
    }];
}

- (void) registerEventsListener:(CDVInvokedUrlCommand*)command {
    [self.audioStreamingDelegate setCallbackId: command.callbackId];
    [self.audioStreamingPlaybackDelegate setCallbackId: command.callbackId];

    CDVPluginResult *result = [CDVPluginResult
            resultWithStatus: CDVCommandStatus_OK
             messageAsString: nil];
    [result setKeepCallbackAsBool: YES];

    [self.commandDelegate sendPluginResult: result callbackId: command.callbackId];
}

- (void) seekTo:(CDVInvokedUrlCommand*)cmd {
    __weak CordovaSpotify* _self = self;
    NSInteger position = [[cmd.arguments objectAtIndex: 0] intValue];

    [self.player seekTo: position / 1000.0 callback: ^(NSError *err) {
        [_self sendResultForCommand: cmd withError: err andSuccess: nil];
    }];
}

- (void) sendResultForCommand:(CDVInvokedUrlCommand*)cmd withError:(NSError*) err andSuccess:(NSString*) success {
    CDVPluginResult *result;

    if (err == nil) {
        result = [CDVPluginResult
                resultWithStatus: CDVCommandStatus_OK
                 messageAsString: success];
    } else {
        result = [CDVPluginResult
                resultWithStatus: CDVCommandStatus_ERROR
                 messageAsString: err.localizedDescription];
    }

    [self.commandDelegate sendPluginResult: result callbackId: cmd.callbackId];
}
@end
