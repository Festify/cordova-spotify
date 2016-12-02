#import "CordovaSpotify.h"
#import <Foundation/Foundation.h>

@implementation CordovaSpotify
- (void) coolMethod:(CDVInvokedUrlCommand*)command {
    NSString* input = [command.arguments objectAtIndex:0];

    CDVPluginResult* pluginResult = [CDVPluginResult
                                     resultWithStatus: CDVCommandStatus_OK
                                     messageAsString: input];

    [self.commandDelegate
     sendPluginResult: pluginResult
     callbackId: command.callbackId];
}
@end
