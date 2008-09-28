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
- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                         handleRequest:(NitroxHTTPRequestMessage *)request;
@end

@interface NitroxHTTPServer : GTMHTTPServer {

}

@end
