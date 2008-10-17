//
//  NitroxCore.h
//  libnitrox
//
//  Created by Robert Sanders on 10/15/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxHTTPServer.h"

@class NitroxApp;
@class NitroxHTTPServerPathDelegate;

@interface NitroxCore : NSObject {
    NSMutableDictionary*       apps;
    NitroxHTTPServer*   server;
    
    NitroxHTTPServerPathDelegate*  rootPathDelegate;
    NitroxHTTPServerPathDelegate*  appPathDelegate;
    
    NSInteger   httpPort;
}

@property (retain) NSDictionary*       apps;
@property (retain) NitroxHTTPServer*   server;
@property (readonly) NSInteger httpPort;

+ (NitroxCore*) singleton;

- (NitroxApp*) createApp;

- (NitroxCore*) init;
- (void) start;
- (void) stop;

@end
