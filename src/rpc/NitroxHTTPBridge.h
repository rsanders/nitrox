//
//  NitroxHTTPBridge.h
//  libnitrox
//
//  Created by Robert Sanders on 10/20/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NitroxHTTP.h"

@class NitroxBridgeClass;

@interface NitroxHTTPBridge : NSObject <NitroxHTTPServerDelegate> {
    NitroxBridgeClass*      bridge;
}

@property (retain) NitroxBridgeClass*      bridge;

- (NitroxHTTPBridge *) initWithBridge:(NitroxBridgeClass *)newbridge;

@end
