//
//  NitroxRPCDispatcher.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NitroxHTTP.h"
#import "NitroxRPC.h"
#import "NitroxRPCCallback.h"

@class NitroxWebViewController;

@interface NitroxRPCDispatcher : NSObject <NitroxHTTPServerDelegate> {
    NitroxStubClass*          stub;
    NitroxWebViewController*  webViewController;
}

- (NitroxRPCDispatcher *) initWithStubClass:(NitroxStubClass *)stub;
- (NitroxRPCDispatcher *) initWithStubClass:(NitroxStubClass *)stub 
                          webViewController:(NitroxWebViewController *)webViewController;

- (void) scheduleCallback:(NitroxRPCCallback *)callback immediate:(BOOL)now;


@property (assign) NitroxWebViewController*  webViewController;

@end
