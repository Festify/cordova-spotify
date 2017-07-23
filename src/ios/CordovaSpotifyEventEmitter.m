#ifndef CordovaSpotifyEventEmitter_m
#define CordovaSpotifyEventEmitter_m
#import "CordovaSpotifyEventEmitter.h"

NSString* getErrorFromMatrix(NSDictionary *matrix, NSNumber *code) {
    NSString *errorString = [matrix objectForKey: code];

    if(!errorString) {
        return @"Unknown";
    }
    return errorString;
}

@implementation CordovaSpotifyEventEmitter

+ (instancetype)eventEmitterWithCommandDelegate:(id <CDVCommandDelegate>)commandDelegate {
    return [[self alloc] initWithCommandDelegate: commandDelegate];
}

- (instancetype)initWithCommandDelegate:(id <CDVCommandDelegate>)commandDelegate {
    self.commandDelegate = commandDelegate;

    return self;
}

- (void)setCallbackId:(NSString *) callbackId {
    self.eventCallbackId = callbackId;
}

- (void)emit:(NSString *)eventName withData:(NSArray *) data {
    if (self.eventCallbackId == nil) {
        return;
    }

    NSDictionary *params = @{
        @"name": eventName,
        @"args": data
    };

    CDVPluginResult *result = [CDVPluginResult resultWithStatus: CDVCommandStatus_OK
                                            messageAsDictionary: params];
    [result setKeepCallbackAsBool:YES];

    [self.commandDelegate sendPluginResult: result
                                callbackId: self.eventCallbackId];
}

@end

#endif
