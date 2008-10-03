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

@interface NitroxHTTPRequest : NSObject {
    GTMHTTPRequestMessage*    requestMessage;
    NSString*                 prefixPath;
    NSString*                 path;
}

@property (retain) GTMHTTPRequestMessage*    requestMessage;
@property (retain) NSString*                 prefixPath;
@property (retain) NSString*                 path;

// designated initializer
- (NitroxHTTPRequest*) initWithRequestMessage:(GTMHTTPRequestMessage*) requestMessage
                                       prefix:(NSString*)prefix
                                         path:(NSString *)path;

- (NitroxHTTPRequest*) initWithRequestMessage:(GTMHTTPRequestMessage*) requestMessage;

- (NitroxHTTPRequest*) nextLevelRequest;

- (NSURL *)URL;

@end

@protocol NitroxHTTPServerDelegate
- (BOOL) willHandlePath:(NSString *)path
            fromRequest:(NitroxHTTPRequest *)request
               onServer:(NitroxHTTPServer *)server;
          
- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                            handleRequest:(NitroxHTTPRequest *)request
                                   atPath:(NSString *)path;
@end

@interface NitroxHTTPServer : GTMHTTPServer  {
    id<NitroxHTTPServerDelegate>         nitroxDelegate;
}

@end
