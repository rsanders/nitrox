//
//  NitroxHTTPServer.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/27/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GTMHTTPServer.h"

@class NitroxHTTPServer;

@interface NitroxHTTPResponseMessage : GTMHTTPResponseMessage {
}
@end

@interface NitroxHTTPRequestMessage : GTMHTTPRequestMessage {
}
@end

@protocol NitroxHTTPServerDelegate
- (BOOL) willHandlePath:(NSString *)path
            fromRequest:(NitroxHTTPRequestMessage *)request
               onServer:(NitroxHTTPServer *)server;
          
- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                            handleRequest:(NitroxHTTPRequestMessage *)request
                                   atPath:(NSString *)path;
@end

@interface NitroxHTTPServer : GTMHTTPServer  {
    id<NitroxHTTPServerDelegate>         nitroxDelegate;
}

@end
