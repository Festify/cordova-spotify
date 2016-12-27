#import "AudioStreamingDelegate.h"

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

@end