#ifndef CordovaEventEmitter_h
#define CordovaEventEmitter_h

#import <Cordova/CDVPlugin.h>

NSString* getErrorFromMatrix(NSDictionary *matrix, NSNumber *code);

@interface CordovaEventEmitter : NSObject
    @property (nonatomic, weak) id <CDVCommandDelegate> commandDelegate;
    @property (nonatomic) NSString *eventCallbackId;
    @property (nonatomic) NSDictionary *codeMatrix;

    + (instancetype)eventEmitterWithCommandDelegate: (id <CDVCommandDelegate>) commandDelegate;
    - (instancetype)initWithCommandDelegate: (id <CDVCommandDelegate>) commandDelegate;
    -(void) setCallbackId:(NSString *) callbackId;
    -(void) emit:(NSString *)eventName withData:(NSArray *) data;
@end
#endif