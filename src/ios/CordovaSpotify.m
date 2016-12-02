#import "CordovaSpotify.h"
#import <Foundation/Foundation.h>

@implementation CordovaSpotify
- (void) coolMethod:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = [CDVPluginResult
                                     resultWithStatus: CDVCommandStatus_OK
                                     messageAsString: @"Hello World!"];

    [self.commandDelegate
     sendPluginResult: pluginResult
     callbackId: command.callbackId];
}
@end
