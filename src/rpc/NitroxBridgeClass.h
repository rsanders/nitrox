//
//  NitroxBridgeClass.h
//
//  Created by Robert Sanders 
//

#import <UIKit/UIKit.h>
#import "NitroxRPC.h"
#import "NitroxRPCCallback.h"
#import "NitroxBool.h"

@class NitroxApp;

@class NitroxWebViewController;

@interface NitroxBridgeClass : NSObject  {
    NitroxApp*               app;
}

@property (readonly) NitroxWebViewController*  webViewController;
@property (retain) NitroxApp*  app;

- (NitroxBridgeClass *) initWithApp:(NitroxApp*)app;

- (id)invoke:(NSString *)method withTarget:(id)object parameters:(NSArray*)parameters;

// - (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args;

- (id) invokeMethod:(NSString *)method withTarget:(id)target parameters:(NSArray *)parameters;
- (id) invokeMethod:(NSString *)method onClass:(NSString*)className parameters:(NSArray *)parameters;

- (NSString *) serialize:(id)object;

- (void) scheduleCallbackScript:(NSString *)jsscript;
- (void) scheduleCallback:(NitroxRPCCallback *)callback immediate:(BOOL)now;

- (id) boolObject:(BOOL)val;

@end
