//
//  WebViewInstance.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/29/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "WebViewInstance.h"

#import "NitroxWebViewController.h"

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

- (void) goHome {
    if (controller) {
        if (!baseURL) {
            baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d/%@", 
                                            [controller httpPort], 
                                            [NitroxHTTPUtils stripLeadingSlash:[url path]]]];
        }
        
        [controller setTitle:name];
        
        if (! [url isFileURL]) {
            url = [self rewriteURL:url];
        }
        
        
        if (baseURL && !noBase) {
            [controller loadRequest:[NSMutableURLRequest requestWithURL:url] baseURL:baseURL];
        } else {
            [controller loadRequest:[NSMutableURLRequest requestWithURL:url]];
        }
    }
}

- (NitroxWebViewController *) controller {
    @synchronized(self) {
        if (!controller) {
            NitroxWebViewController *wvc = [[NitroxWebViewController alloc] 
                                            initWithNibName:@"NitroxWebView" bundle:[NSBundle mainBundle]];
            
            controller = wvc;
            
            [self goHome];
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
