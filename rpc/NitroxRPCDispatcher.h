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

@interface NitroxRPCDispatcher : NSObject <NitroxHTTPServerDelegate> {
    NitroxStubClass*          stub;
}

- (NitroxRPCDispatcher *) initWithStubClass:(NitroxStubClass *)stub;

@end
