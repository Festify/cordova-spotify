#import "CordovaSpotify.h"
#import <Foundation/Foundation.h>

@implementation CordovaSpotify

- (void)pluginInitialize {
    // Tell iOS to play audio even in background and when the ringer is silent
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];

    // Initialize delegates for event handling
    __weak id <CDVCommandDelegate> _commandDelegate = self.commandDelegate;
    self.audioStreamingDelegate = [AudioStreamingDelegate eventEmitterWithCommandDelegate: _commandDelegate];
    self.audioStreamingPlaybackDelegate = [AudioStreamingPlaybackDelegate eventEmitterWithCommandDelegate: _commandDelegate];

    // 512 MB disk caching
    self.cache = [[SPTDiskCache alloc] initWithCapacity: 1024 * 1024 * 512];
}

- (void) loginAndPlay:(NSString*)accessToken 
              withUri:(NSString*)trackUri 
              fromPos:(NSInteger)positionMs 
          withCommand:(CDVInvokedUrlCommand*)command {
    __weak CordovaSpotify* _self = self;
    [self.audioStreamingDelegate handleLoginWithCallback: ^(NSError* err) {
        if (err) {
            _self.currentToken = nil;

            [_self sendResultForCommand: command
                          withErrorType: @"login_failed"
                               andDescr: err.localizedDescription
                             andSuccess: nil];
            return;
        }

        _self.currentToken = accessToken;
        [_self doPlay: trackUri 
              fromPos: positionMs 
          withCommand: command];
    }];

    [self.player loginWithAccessToken: accessToken];
}

- (void) initAndPlay:(NSString*)clientId
           withToken:(NSString*)accessToken 
             withUri:(NSString*)trackUri 
             fromPos:(NSInteger)positionMs 
         withCommand:(CDVInvokedUrlCommand*)command {
    NSError* startError = nil;
    BOOL success = [[SPTAudioStreamingController sharedInstance] 
        startWithClientId: clientId 
                    error: &startError];
    if (!success) {
        self.currentClientId = nil;
        self.player.delegate = nil;
        self.player.playbackDelegate = nil;
        self.player = nil;

        if (startError) {
            [self sendResultForCommand: command
                         withErrorType: @"player_init_failed"
                              andDescr: startError.localizedDescription
                            andSuccess: nil];
        } else {
            [self sendResultForCommand: command
                         withErrorType: @"player_init_failed"
                              andDescr: @"Player could not be started"
                            andSuccess: nil];
        }
        return;
    }

    self.currentClientId = clientId;
    self.player = [SPTAudioStreamingController sharedInstance];
    self.player.delegate = self.audioStreamingDelegate;
    self.player.playbackDelegate = self.audioStreamingPlaybackDelegate;

    [self loginAndPlay: accessToken
               withUri: trackUri
               fromPos: positionMs
           withCommand: command];
}

- (void) doPlay:(NSString*)trackUri 
        fromPos:(NSInteger)positionMs 
    withCommand:(CDVInvokedUrlCommand*)command {
    // Take over audio session
    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (!success) {
        if (activationError) {
            [self sendResultForCommand: command
                         withErrorType: @"playback_failed"
                              andDescr: activationError.localizedDescription
                            andSuccess: nil];
        } else {
            [self sendResultForCommand: command
                         withErrorType: @"playback_failed"
                              andDescr: @"Audio session could not be started"
                            andSuccess: nil];
        }
        return;
    }

    __weak CordovaSpotify* _self = self;
    SPTErrorableOperationCallback cb = ^(NSError* err) {
        if (err) {
            [_self sendResultForCommand: command
                         withErrorType: @"playback_failed"
                              andDescr: err.localizedDescription
                            andSuccess: nil];
        } else {
            [_self sendResultForCommand: command
                         withErrorType: nil
                              andDescr: nil
                            andSuccess: nil];
        }
    };

    [self.player playSpotifyURI: trackUri 
              startingWithIndex: 0 
           startingWithPosition: positionMs / 1000.0 
                       callback: cb];
}

- (void) logout:(void (^)(void))callback {
    if ([self.player loggedIn]) {
        [self.audioStreamingDelegate handleLogoutWithCallback: callback];
        [self.player logout];
    } else {
        callback();
    }
}

- (void) sendResultForCommand:(CDVInvokedUrlCommand*)cmd 
                withErrorType:(NSString*)err 
                     andDescr:(NSString*)errDescription
                   andSuccess:(NSString*)success {
    CDVPluginResult *result;

    if (err == nil) {
        result = [CDVPluginResult
                resultWithStatus: CDVCommandStatus_OK
                 messageAsString: success];
    } else {
        result = [CDVPluginResult
                resultWithStatus: CDVCommandStatus_ERROR
             messageAsDictionary: @{
                 @"type": err,
                 @"msg": errDescription
             }];
    }

    [self.commandDelegate sendPluginResult: result callbackId: cmd.callbackId];
}

/*
 * API FUNCTIONS
 */

- (void) getPosition:(CDVInvokedUrlCommand*)command {
    double durationMs = 0.0;
    SPTAudioStreamingController* player = self.player;

    if (player) {
        durationMs = [[player playbackState] position] * 1000.0;
    }

    CDVPluginResult *result = [CDVPluginResult
            resultWithStatus: CDVCommandStatus_OK
             messageAsDouble: durationMs];

    [self.commandDelegate sendPluginResult: result callbackId: command.callbackId];
}

- (void) play:(CDVInvokedUrlCommand*)command {
    __weak CordovaSpotify* _self = self;

    NSString* trackUri = [command.arguments objectAtIndex: 0];
    NSString* accessToken = [command.arguments objectAtIndex: 1];
    NSString* clientId = [command.arguments objectAtIndex: 2];
    NSInteger from = [[command.arguments objectAtIndex: 3] intValue];

    if (!self.player) {
        [self initAndPlay: clientId 
                withToken: accessToken 
                  withUri: trackUri 
                  fromPos: from 
              withCommand: command];
    } else if (![clientId isEqualToString: self.currentClientId]) {
        [self logout: ^() {
            [_self initAndPlay: clientId 
                     withToken: accessToken 
                       withUri: trackUri 
                       fromPos: from 
                   withCommand: command];
        }];
    } else if (![accessToken isEqualToString: self.currentToken]) {
        [self logout: ^() {
            [_self loginAndPlay: accessToken 
                        withUri: trackUri 
                        fromPos: from 
                    withCommand: command];
        }];
    } else {
        [self doPlay: trackUri fromPos: from withCommand: command];
    }
}

- (void) pause:(CDVInvokedUrlCommand*)command {
    SPTAudioStreamingController* player = self.player;
    if (!player) {
        [self sendResultForCommand: command
                     withErrorType: nil
                          andDescr: nil
                        andSuccess: nil];
        return;
    }

    __weak CordovaSpotify* _self = self;
    [player setIsPlaying: NO callback: ^(NSError* err) {
        if (!err) {
            [_self sendResultForCommand: command
                          withErrorType: nil
                               andDescr: nil
                             andSuccess: nil];
        } else {
            [_self sendResultForCommand: command 
                          withErrorType: @"pause_failed" 
                               andDescr: err.localizedDescription
                             andSuccess: nil];
        }
    }];
}

- (void) resume:(CDVInvokedUrlCommand*)command {
    SPTAudioStreamingController* player = self.player;
    if (!player) {
        [self sendResultForCommand: command
                     withErrorType: @"not_playing"
                          andDescr: @"The Spotify SDK currently does not play music. Play a track to resume it."
                        andSuccess: nil];
        return;
    }

    __weak CordovaSpotify* _self = self;
    [player setIsPlaying: YES callback: ^(NSError* err) {
        if (!err) {
            [_self sendResultForCommand: command
                          withErrorType: nil
                               andDescr: nil
                             andSuccess: nil];
        } else {
            [_self sendResultForCommand: command 
                          withErrorType: @"resume_failed" 
                               andDescr: err.localizedDescription
                             andSuccess: nil];
        }
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

- (void) seekTo:(CDVInvokedUrlCommand*)command {
    SPTAudioStreamingController* player = self.player;
    if (!player || ![[player playbackState] isPlaying]) {
        [self sendResultForCommand: command
                     withErrorType: @"not_playing"
                          andDescr: @"The Spotify SDK currently does not play music. Play a track to seek."
                        andSuccess: nil];
        return;
    }

    __weak CordovaSpotify* _self = self;
    NSInteger position = [[command.arguments objectAtIndex: 0] intValue];

    [player seekTo: position / 1000.0 callback: ^(NSError *err) {
        if (!err) {
            [_self sendResultForCommand: command
                          withErrorType: nil
                               andDescr: nil
                             andSuccess: nil];
        } else {
            [_self sendResultForCommand: command 
                          withErrorType: @"seek_failed" 
                               andDescr: err.localizedDescription
                             andSuccess: nil];
        }
    }];
}
@end
