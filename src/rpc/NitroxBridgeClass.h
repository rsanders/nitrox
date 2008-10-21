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

// js->objc: invocation

- (id) invoke:(NSString *)method withTarget:(id)object parameters:(NSArray*)parameters;
- (id) invokeMethod:(NSString *)method withTarget:(id)target parameters:(NSArray *)parameters;

// js->objc: description/introspection of objects

- (id) resolveObjectRef:(id)ref;
- (id) describeObject:(id)object;

// objc->js: callbacks
- (void) scheduleCallbackScript:(NSString *)jsscript;
- (void) scheduleCallback:(NitroxRPCCallback *)callback immediate:(BOOL)now;

// data transformation
- (NSString *) serialize:(id)object;
- (id) boolObject:(BOOL)val;

@end
