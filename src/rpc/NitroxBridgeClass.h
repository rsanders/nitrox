//
//  NitroxBridgeClass.h
//
//  Created by Robert Sanders 
//

#import <UIKit/UIKit.h>
#import "NitroxHTTP.h"
#import "NitroxRPC.h"
#import "NitroxRPCCallback.h"
#import "NitroxBool.h"

@class NitroxApp;

@class NitroxWebViewController;

@interface NitroxBridgeClass : NSObject <NitroxHTTPServerDelegate> {
    NitroxApp*               app;
}

@property (readonly) NitroxWebViewController*  webViewController;
@property (retain) NitroxApp*  app;

- (NitroxBridgeClass *) initWithApp:(NitroxApp*)app;


- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args;

- (NSString *) serialize:(id)object;

- (void) scheduleCallbackScript:(NSString *)jsscript;
- (void) scheduleCallback:(NitroxRPCCallback *)callback immediate:(BOOL)now;

- (id) boolObject:(BOOL)val;

//@property (retain,readonly)  NSString*    className;
//@property (retain,readonly)  NSString*    classMethods;
//@property (retain,readonly)  NSString*    instanceMethods;   

//- (id) newInstance;
//- (id) newInstanceWithArgs:(NSDictionary *)args;
// - (id) object:(id)object invoke:(NSString *)method args:(NSDictionary *)args;



@end
