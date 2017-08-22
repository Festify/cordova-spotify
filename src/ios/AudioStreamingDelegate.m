#import "AudioStreamingDelegate.h"

@implementation AudioStreamingDelegate

- (instancetype)initWithCommandDelegate: (id <CDVCommandDelegate>) commandDelegate {
    self = [super initWithCommandDelegate: commandDelegate];

    if(self) {
        self.codeMatrix = @{
                [NSNumber numberWithInteger: SPTErrorCodeNoError]: @"NoError",
                [NSNumber numberWithInteger: SPTErrorCodeFailed]: @"Failed",
                [NSNumber numberWithInteger: SPTErrorCodeInitFailed]: @"InitFailed",
                [NSNumber numberWithInteger: SPTErrorCodeWrongAPIVersion]: @"WrongAPIVersion",
                [NSNumber numberWithInteger: SPTErrorCodeNullArgument]: @"NullArgument",
                [NSNumber numberWithInteger: SPTErrorCodeInvalidArgument]: @"InvalidArgument",
                [NSNumber numberWithInteger: SPTErrorCodeUninitialized]: @"Uninitialized",
                [NSNumber numberWithInteger: SPTErrorCodeAlreadyInitialized]: @"AlreadyInitialized",
                [NSNumber numberWithInteger: SPTErrorCodeBadCredentials]: @"BadCredentials",
                [NSNumber numberWithInteger: SPTErrorCodeNeedsPremium]: @"NeedsPremium",
                [NSNumber numberWithInteger: SPTErrorCodeTravelRestriction]: @"TravelRestriction",
                [NSNumber numberWithInteger: SPTErrorCodeApplicationBanned]: @"ApplicationBanned",
                [NSNumber numberWithInteger: SPTErrorCodeGeneralLoginError]: @"GeneralLoginError",
                [NSNumber numberWithInteger: SPTErrorCodeUnsupported]: @"Unsupported",
                [NSNumber numberWithInteger: SPTErrorCodeNotActiveDevice]: @"NotActiveDevice",
                [NSNumber numberWithInteger: SPTErrorCodeGeneralPlaybackError]: @"GeneralPlaybackError",
                [NSNumber numberWithInteger: SPTErrorCodePlaybackRateLimited]: @"PlaybackRateLimited",
        };
    }

    return self;
}

- (void)audioStreamingDidDisconnect:(SPTAudioStreamingController *)audioStreaming {
    [self emit:@"networkdisconnect" withData:@[]];
}

- (void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    if (self.logoutCallback) {
        self.logoutCallback();
        self.logoutCallback = nil;
    }

    [self emit:@"loggedout" withData:@[]];
}

- (void)audioStreamingDidLogin:(SPTAudioStreamingController *)audioStreaming {
    if (self.loginCallback) {
        self.loginCallback(nil);
        self.loginCallback = nil;
    }

    [self emit:@"loggedin" withData:@[]];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    [self emit:@"connectionmessage" withData:@[message]];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveError:(NSError *)error {
    if (self.loginCallback) {
        self.loginCallback(error);
        self.loginCallback = nil;

        return;
    }

    [self emit:@"playbackerror" withData:@[getErrorFromMatrix(self.codeMatrix, [NSNumber numberWithInteger: [error code]])]];
}

- (void) handleLoginWithCallback:(void (^)(NSError* err))callback {
    self.loginCallback = callback;
}

- (void) handleLogoutWithCallback:(void (^)(void))callback {
    self.logoutCallback = callback;
}

@end
