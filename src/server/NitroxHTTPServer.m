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

@implementation NitroxHTTPRequest

@synthesize requestMessage, prefixPath, path;

- (NitroxHTTPRequest*) initWithRequestMessage:(GTMHTTPRequestMessage*) requestMessageArg
                                       prefix:(NSString*)prefixArg
                                         path:(NSString *)pathArg
{
    self.requestMessage = requestMessageArg;
    self.prefixPath = prefixArg;
    self.path = pathArg;
    
    return self;
}

- (NitroxHTTPRequest*) initWithRequestMessage:(GTMHTTPRequestMessage*) requestMessageArg
{
    return [self initWithRequestMessage:requestMessageArg prefix:@"" path:[[requestMessageArg URL] path]];
}

- (NitroxHTTPRequest*) fullPath
{
    return [NSString stringWithFormat:@"%@/%@", prefixPath, path];
}

// create a request for the next level down
- (NitroxHTTPRequest*) nextLevelRequest
{
    // either no further path or a path that cannot be subdivided
    if ([self.path isEqualToString:@""]
        || [(NSString *)self.path rangeOfString:@"/"].length == 0) 
    {
        NSLog(@"in nextLevelRequest, tried to get subpath of non-subpathable path: %@", path);
        return Nil;
    }
    
    // move a path component from the path to the prefix
    NSString *newPrefix = [NSString stringWithFormat:@"%@/%@",
                           prefixPath, [NitroxHTTPUtils getLeadingPathElement:path]];
                        
    NSString *newPath = [NitroxHTTPUtils stripLeadingPathElement:path];
    
    return [[[NitroxHTTPRequest alloc] initWithRequestMessage:requestMessage 
                prefix:newPrefix
                path:newPath] autorelease];
}

- (NSURL*) URL {
    return [requestMessage URL];
}

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

    NitroxHTTPRequest *nRequest = [[NitroxHTTPRequest alloc] initWithRequestMessage:request];
    
    NitroxHTTPResponseMessage *response = 
        [nitroxDelegate httpServer:self 
                     handleRequest:nRequest
                            atPath:path];
    
    if (!response) {
        response = [NitroxHTTPResponseMessage emptyResponseWithCode:404];
    }
    
    [nRequest release];

    return response;
}

@end
