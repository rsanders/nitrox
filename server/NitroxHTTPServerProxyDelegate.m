//
//  NitroxHTTPServerProxyDelegate.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxHTTPServerProxyDelegate.h"

#import "CJSONDeserializer.h"

#import "NibwareUrlUtils.h"

/*
 * GET /proxy/ajax?args=JSONARGS
 * POST /proxy/ajax - body contains args
 *
 * GET /proxy/transparent/
 *
 *
 */

@implementation NitroxHTTPServerProxyDelegate

- (NitroxHTTPServerProxyDelegate *) init {
    [super init];
    return self;
}

- (BOOL) willHandlePath:(NSString *)path
            fromRequest:(NitroxHTTPRequest *)request
               onServer:(NitroxHTTPServer *)server
{
    return YES;
}

- (NitroxHTTPResponseMessage *)doRetrieve:(NitroxHTTPRequest *)request atPath:(NSString *)path
{
    NSString* query = [[[request requestMessage] URL] query];
    NSDictionary* args = [NibwareUrlUtils parseQueryString:query];
    
    NSString *url;
    
    if (! (url = [args objectForKey:@"url"])) {
        return [NitroxHTTPResponseMessage emptyResponseWithCode:400];
    }
    
    NSURLResponse *response = Nil;
    NSError *error = Nil;
    NSURLRequest *proxyRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    NSData *data = [NSURLConnection sendSynchronousRequest:proxyRequest returningResponse:&response error:&error];
    
    if (!data || error) {
        NSLog(@"error retrieving URL %@: %@", url, error);
        return [NitroxHTTPResponseMessage emptyResponseWithCode:500];
    }
    
    int statusCode = 200;
    if ([response respondsToSelector:@selector(statusCode)]) {
        statusCode = [(NSHTTPURLResponse *)response statusCode];
    }
    return [NitroxHTTPResponseMessage responseWithBody:data 
                                           contentType:[response MIMEType] 
                                            statusCode:statusCode];
}

- (NitroxHTTPResponseMessage *)doAjax:(NitroxHTTPRequest *)request atPath:(NSString *)path
{
    return [NitroxHTTPResponseMessage emptyResponseWithCode:404];
}


- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                            handleRequest:(NitroxHTTPRequest *)request
                                   atPath:(NSString *)path
{
    if ([path isEqualToString:@"retrieve"]) {
        return [self doRetrieve:request atPath:path];
    } else if ([path isEqualToString:@"ajax"]) {
        return [self doAjax:request atPath:path];        
    } else {
        return [NitroxHTTPResponseMessage emptyResponseWithCode:404];
    }
}

@end
