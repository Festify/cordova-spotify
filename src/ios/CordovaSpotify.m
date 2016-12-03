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
                            [[NSNotificationCenter defaultCenter]
                                    removeObserver: observer];
                            return [[SPTAuth defaultInstance]
                                    handleAuthCallbackWithTriggeredAuthURL: url
                                                                  callback: cb];
                        }
                    }];

    [self.viewController presentViewController:authViewController animated:YES completion:nil];
}

- (void) play:(CDVInvokedUrlCommand*)command {
    NSString* url = [command.arguments objectAtIndex:0];

    __weak CordovaSpotify* _self = self;
    [self.player playSpotifyURI: url
              startingWithIndex: 0
           startingWithPosition: 0
                       callback: ^(NSError *err) {
        CDVPluginResult* res;

        if (err == nil) {
            res = [CDVPluginResult
                    resultWithStatus: CDVCommandStatus_OK
                     messageAsString: url];
        } else {
            res = [CDVPluginResult
                    resultWithStatus: CDVCommandStatus_ERROR
                     messageAsString: err.localizedDescription];
        }

        [_self.commandDelegate sendPluginResult: res callbackId: command.callbackId];
    }];
}

- (void) audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    self.isLoggedIn = YES;
}

- (void) audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    self.isLoggedIn = NO;
}
@end
