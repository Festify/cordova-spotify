#import "AudioStreamingDelegate.h"

NSString* getErrorString(NSError *error) {
    NSDictionary *codeMatrix = @{
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

    NSString *errorString = [codeMatrix objectForKey: [NSNumber numberWithInteger: [error code]]];

    if(!errorString) {
        return @"Unknown";
    }
    return errorString;
}

@implementation AudioStreamingDelegate

- (void)audioStreamingDidDisconnect:(SPTAudioStreamingController *)audioStreaming {
    [self emit:@"networkdisconnect" withData:@[]];
}

- (void)audioStreamingDidLogout:(SPTAudioStreamingController *)audioStreaming {
    [self emit:@"loggedout" withData:@[]];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message {
    [self emit:@"connectionmessage" withData:@[message]];
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveError:(NSError *)error {
    [self emit:@"playbackerror" withData:@[getErrorString(error)]];
}

@end