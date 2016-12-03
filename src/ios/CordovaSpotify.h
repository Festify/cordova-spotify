//
//  CordovaSpotify.h
//  CordovaSpotify
//
//  Created by Leo Bernard on 02/12/2016.
//
//

#ifndef CordovaSpotify_h
#define CordovaSpotify_h

#import <Cordova/CDVPlugin.h>
#import <SpotifyAuthentication/SpotifyAuthentication.h>
#import <SafariServices/SafariServices.h>

@interface CordovaSpotify : CDVPlugin
- (void) authenticate:(CDVInvokedUrlCommand*)command;
@end

#endif /* CordovaSpotify_h */
