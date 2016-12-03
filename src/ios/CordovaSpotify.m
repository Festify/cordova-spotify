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
            @"encryptedRefreshToken": ([session encryptedRefreshToken] == nil) ?[NSNull null] : [session encryptedRefreshToken],
            @"accessToken": [session accessToken],
            @"tokenType": [session tokenType],
            @"expirationDate": dateToString([session expirationDate])
    };
}

@implementation CordovaSpotify
- (void) authenticate:(CDVInvokedUrlCommand*)command {
    NSString* urlScheme = [command.arguments objectAtIndex:0];
    NSString* clientId  = [command.arguments objectAtIndex:1];
    NSArray* scopes     = [command.arguments objectAtIndex:2];

    __weak CordovaSpotify* _self = self;

    [self.commandDelegate runInBackground:^{
        SPTAuthCallback cb = ^(NSError* err, SPTSession* session) {
            CDVPluginResult* pluginResult;

            if(err == nil) {
                pluginResult = [CDVPluginResult
                        resultWithStatus: CDVCommandStatus_OK
                         messageAsDictionary: sessionToDict(session)];
            } else {
                pluginResult = [CDVPluginResult
                        resultWithStatus: CDVCommandStatus_ERROR
                         messageAsString: err.localizedDescription];
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
                        usingBlock: ^(NSNotification* note){
                            NSURL* url = [note object];
                            if([[SPTAuth defaultInstance] canHandleURL: url]) {
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

        [_self.viewController presentViewController:authViewController animated:YES completion:nil];
    }];
}
@end
