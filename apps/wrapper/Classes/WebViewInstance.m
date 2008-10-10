//
//  WebViewInstance.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/29/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "WebViewInstance.h"

#import "NitroxWebViewController.h"

@implementation WebViewInstance

@synthesize name, noBase;

+ (WebViewInstance *) instanceWithURL:(NSURL *)url baseURL:(NSURL *)baseURL name:(NSString *)name
{
    WebViewInstance *wvi = [[WebViewInstance alloc] autorelease];
    wvi->url = [url retain];
    wvi->baseURL = [baseURL retain];
    wvi->name = [name retain];
    return wvi;
}

- (NSURL *)rewriteURL:(NSURL *)oldURL {
    if ([[oldURL host] isEqualToString:@"localhost"]) {
        NSURL* rewrittenURL = [[NSURL URLWithString:[oldURL path] relativeToURL:baseURL] absoluteURL];
        return rewrittenURL;
    }
    return oldURL;
}

- (UIViewController *) controller {
    @synchronized(self) {
        if (!controller) {
            NitroxWebViewController *wvc = [[NitroxWebViewController alloc] 
                                            initWithNibName:@"NitroxWebView" bundle:[NSBundle mainBundle]];
            
            if (!baseURL) {
                baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d/%@", 
                                                [wvc httpPort], 
                                                [NitroxHTTPUtils stripLeadingSlash:[url path]]]];
            }
            
            [wvc setTitle:name];
            
            if (! [url isFileURL]) {
                url = [self rewriteURL:url];
            }
            

            if (baseURL && !noBase) {
                [wvc loadRequest:[NSMutableURLRequest requestWithURL:url] baseURL:baseURL];
            } else {
                [wvc loadRequest:[NSMutableURLRequest requestWithURL:url]];
            }
            
            controller = wvc;
        }
    }
    return controller;
}

- (void) dealloc {
    [url release];
    [baseURL release];
    [name release];
    [controller release];
    [super dealloc];
}

@end
