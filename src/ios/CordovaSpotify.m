#import "CordovaSpotify.h"
#import <Foundation/Foundation.h>

NSString *dateToString(NSDate* date) {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss O"];
    return [formatter stringFromDate:date];
}

NSDictionary *sessionToDict(SPTSession* session) {
    return @{
            @"canonicalUsername": [session canonicalUsername],
            @"encryptedRefreshToken": ([session encryptedRefreshToken] == nil) ? [NSNull null] : [session encryptedRefreshToken],
            @"accessToken": [session accessToken],
            @"tokenType": [session tokenType],
            @"expirationDate": dateToString([session expirationDate])
    };
}

@implementation CordovaSpotify

- (void)pluginInitialize {
    self.isLoggedIn = NO;

    [SPTAuth defaultInstance].sessionUserDefaultsKey = @"CordovaSpotifySession";

    // Initialize delegates for event handling
    __weak id <CDVCommandDelegate> _commandDelegate = self.commandDelegate;
    self.audioStreamingDelegate = [AudioStreamingDelegate eventEmitterWithCommandDelegate: _commandDelegate];
    self.audioStreamingPlaybackDelegate = [AudioStreamingPlaybackDelegate eventEmitterWithCommandDelegate: _commandDelegate];

    self.player = [SPTAudioStreamingController sharedInstance];
    self.player.delegate = self.audioStreamingDelegate;
    self.player.playbackDelegate = self.audioStreamingPlaybackDelegate;
}

- (void) authenticate:(CDVInvokedUrlCommand*)command {
    NSString* urlScheme = [command.arguments objectAtIndex:0];
    NSString* clientId  = [command.arguments objectAtIndex:1];
    NSArray* scopes     = [command.arguments objectAtIndex:2];

    // Setup AVAudioSession for Background Audio
    NSError *categoryError = nil;
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&categoryError];
    if (categoryError) {
        [self sendResultForCommand:command withError:categoryError andSuccess:nil];
        return;
    }

    SPTAuth* auth = [SPTAuth defaultInstance];
    auth.clientID = clientId;
    auth.redirectURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@://callback", urlScheme]];
    auth.requestedScopes = scopes;

    if ([command.arguments count] >= 5 &&
        [[command.arguments objectAtIndex: 3] isKindOfClass: [NSString class]] &&
        [[command.arguments objectAtIndex: 4] isKindOfClass: [NSString class]]) {
        NSString* tokenSwapURL = [command.arguments objectAtIndex: 3];
        auth.tokenSwapURL = [NSURL URLWithString: tokenSwapURL];
        NSString* tokenRefreshURL = [command.arguments objectAtIndex: 4];
        auth.tokenRefreshURL = [NSURL URLWithString: tokenRefreshURL];
    }

    NSURL *authUrl = [auth spotifyWebAuthenticationURL];
    SFSafariViewController* authViewController = [[SFSafariViewController alloc] initWithURL:authUrl];

    __weak CordovaSpotify* _self = self;

    SPTAuthCallback cb = ^(NSError* err, SPTSession* spotSession) {
        [_self initSession:spotSession withClientId: clientId andError:err andCommand:command];
    };

    __block id observer = [[NSNotificationCenter defaultCenter]
            addObserverForName: CDVPluginHandleOpenURLNotification
                        object: nil
                         queue: nil
                    usingBlock: ^(NSNotification* note) {
                        NSURL* url = [note object];
                        if ([[SPTAuth defaultInstance] canHandleURL: url]) {
                            [authViewController.presentingViewController
                                    dismissViewControllerAnimated: YES
                                                       completion: nil];
                            [[NSNotificationCenter defaultCenter] removeObserver: observer];
                            return [[SPTAuth defaultInstance]
                                    handleAuthCallbackWithTriggeredAuthURL: url
                                                                  callback: cb];
                        }
                    }];

    [self.viewController presentViewController:authViewController animated:YES completion:nil];
}

- (void) login:(CDVInvokedUrlCommand*)command {
    NSString* clientId = [command.arguments objectAtIndex:0];
    NSString* tokenRefreshURL = [command.arguments objectAtIndex:1];

    [SPTAuth defaultInstance].tokenRefreshURL = [NSURL URLWithString:tokenRefreshURL];

    SPTSession* session = [[SPTAuth defaultInstance] session];
    if(!session) {
        [self sendResultForCommand:command withError:nil andSuccess:nil];
        return;
    }

    __weak CordovaSpotify* _self = self;

    [[SPTAuth defaultInstance] renewSession: session callback: ^(NSError* err, SPTSession* spotSession) {
        [_self initSession:spotSession withClientId: clientId andError:err andCommand:command];
    }];
}

- (void) getPosition:(CDVInvokedUrlCommand*)command {
    double durationMs = [[self.player playbackState] position] * 1000.0;

    CDVPluginResult *result = [CDVPluginResult
            resultWithStatus: CDVCommandStatus_OK
             messageAsDouble: durationMs];
    [self.commandDelegate sendPluginResult: result callbackId: command.callbackId];
}

- (void) play:(CDVInvokedUrlCommand*)command {
    __weak CordovaSpotify* _self = self;

    // Take over audio session
    NSError *activationError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
    if (!success) {
        if (activationError) {
            [self sendResultForCommand:command withError:activationError andSuccess:nil];
        } else {
            [self sendResultForCommand:command
                              withError:[NSError errorWithDomain:@"AudioSession" code:-1 userInfo:@{
                                      NSLocalizedDescriptionKey: @"Audio session could not be activated"
                              }]
                             andSuccess:nil];
        }
        return;
    }

    SPTErrorableOperationCallback cb = ^(NSError* err) {
        [_self sendResultForCommand:command withError:err andSuccess:nil];
    };

    // If we're called with a Spotify link, play it, otherwise
    // just resume playback of the current track.
    if ([command.arguments count] > 0 && [[command.arguments objectAtIndex:0] isKindOfClass: [NSString class]]) {
        NSString* url = [command.arguments objectAtIndex:0];
        [self.player playSpotifyURI: url startingWithIndex: 0 startingWithPosition: 0 callback: cb];
    } else {
        [self.player setIsPlaying: YES callback: cb];
    }
}

- (void) pause:(CDVInvokedUrlCommand*)command {
    __weak CordovaSpotify* _self = self;

    [self.player setIsPlaying: NO callback: ^(NSError* err) {
        [_self sendResultForCommand:command withError:err andSuccess:nil];
    }];
}

- (void) registerEventsListener:(CDVInvokedUrlCommand*)command {
    [self.audioStreamingDelegate setCallbackId:command.callbackId];
    [self.audioStreamingPlaybackDelegate setCallbackId:command.callbackId];

    CDVPluginResult *result = [CDVPluginResult
            resultWithStatus: CDVCommandStatus_OK
             messageAsString: nil];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult: result callbackId: command.callbackId];
}

- (void) audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    self.isLoggedIn = YES;
}

- (void) audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    self.isLoggedIn = NO;
}

- (void) initSession:(SPTSession*)session withClientId:(NSString*)clientId andError:(NSError*)err andCommand:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult;

    if (err != nil || ![self.player startWithClientId: clientId error: &err]) {
        pluginResult = [CDVPluginResult
                resultWithStatus: CDVCommandStatus_ERROR
                 messageAsString: err.localizedDescription];
    } else {
        [self.player loginWithAccessToken: [session accessToken]];

        [SPTAuth defaultInstance].session = session;

        pluginResult = [CDVPluginResult
                resultWithStatus: CDVCommandStatus_OK
             messageAsDictionary: sessionToDict(session)];
    }

    [self.commandDelegate
            sendPluginResult: pluginResult
                  callbackId: command.callbackId];
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
