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
            @"tokenType": [session tokenType],
            @"expirationDate": dateToString([session expirationDate])
    };
}

@implementation CordovaSpotify
- (void)pluginInitialize {
    self.isLoggedIn = NO;

    self.player = [SPTAudioStreamingController sharedInstance];
    self.player.delegate = self;
}

- (void) authenticate:(CDVInvokedUrlCommand*)command {
    self.currentCallbackId = command.callbackId;
    NSString* urlScheme = [command.arguments objectAtIndex:0];
    NSString* clientId  = [command.arguments objectAtIndex:1];
    NSArray* scopes     = [command.arguments objectAtIndex:2];

    __weak CordovaSpotify* _self = self;

    SPTAuthCallback cb = ^(NSError* err, SPTSession* spotSession) {
        CDVPluginResult* pluginResult;

        if (err != nil || ![_self.player startWithClientId: clientId error: &err]) {
            pluginResult = [CDVPluginResult
                    resultWithStatus: CDVCommandStatus_ERROR
                     messageAsString: err.localizedDescription];
        } else {
            _self.session = spotSession;
            [_self.player loginWithAccessToken: [spotSession accessToken]];

            pluginResult = [CDVPluginResult
                    resultWithStatus: CDVCommandStatus_OK
                 messageAsDictionary: sessionToDict(spotSession)];
        }

        [_self.commandDelegate
                sendPluginResult: pluginResult
                      callbackId: command.callbackId];
    };

    SPTAuth* auth = [SPTAuth defaultInstance];
    auth.clientID = clientId;
    auth.redirectURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@://callback", urlScheme]];
    auth.sessionUserDefaultsKey = @"FestifySession";
    auth.requestedScopes = scopes;

    NSURL *authUrl = [auth spotifyWebAuthenticationURL];
    SFSafariViewController* authViewController = [[SFSafariViewController alloc] initWithURL:authUrl];

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

- (void) play:(CDVInvokedUrlCommand*)command {
    self.currentCallbackId = command.callbackId;

    __weak CordovaSpotify* _self = self;
    SPTErrorableOperationCallback cb = ^(NSError* err) {
        [_self sendResultWithError:err andSuccess:nil];
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
    self.currentCallbackId = command.callbackId;

    __weak CordovaSpotify* _self = self;

    [self.player setIsPlaying: NO callback: ^(NSError* err) {
        [_self sendResultWithError:err andSuccess:nil];
    }];
}

- (void) setVolume:(CDVInvokedUrlCommand*)command {
    self.currentCallbackId = command.callbackId;
    double volume = [[command.arguments objectAtIndex: 0] doubleValue];

    __weak CordovaSpotify* _self = self;

    [self.player setVolume: volume callback: ^(NSError* error) {
        [_self sendResultWithError: error andSuccess:@""];
    }];
}

- (void) audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    self.isLoggedIn = YES;
}

- (void) audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    self.isLoggedIn = NO;
}

- (void) sendResultWithError:(NSError*) err andSuccess:(NSString*) success {
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

    [self.commandDelegate sendPluginResult: result callbackId: self.currentCallbackId];
}
@end
