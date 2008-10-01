//
//  NitroxHTTPServer.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/27/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxHTTPServer.h"
#import "NitroxHTTPUtils.h"


@implementation NitroxHTTPResponseMessage
@end

@implementation NitroxHTTPRequestMessage
@end

@implementation NitroxHTTPServer

- (NitroxHTTPServer *)initWithDelegate:(id<NitroxHTTPServerDelegate>)delegate {
    [super initWithDelegate:self];
    nitroxDelegate = delegate;
    return self;
}

- (GTMHTTPResponseMessage *)httpServer:(GTMHTTPServer *)server
                         handleRequest:(GTMHTTPRequestMessage *)request
{
    NSString *path = [NitroxHTTPUtils getLeadingPathElement:[[request URL] path]];

    // TODO: fix the bad type-casting up here
    NitroxHTTPResponseMessage *response = 
        [nitroxDelegate httpServer:self handleRequest:(NitroxHTTPRequestMessage*)request atPath:path];
    
    if (!response) {
        response = [NitroxHTTPResponseMessage emptyResponseWithCode:404];
    }
    
    
    return response;
}

@end
