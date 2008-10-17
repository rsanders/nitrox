//
//  WebViewInstance.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/29/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "AppInstance.h"

#import "NitroxWebViewController.h"

#import "NitroxCore.h"
#import "NitroxApp.h"

@implementation AppInstance

@synthesize name, noBase, app;

+ (AppInstance *) instanceWithURL:(NSURL *)url baseURL:(NSURL *)baseURL name:(NSString *)name
{
    AppInstance *wvi = [[AppInstance alloc] autorelease];
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
    if (app) {
        NitroxWebViewController *wvc = [app webViewController];
        [wvc setTitle:name];

        if (!baseURL) {
            baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%d/%@", 
                                            [[NitroxCore singleton] httpPort], 
                                            [NitroxHTTPUtils stripLeadingSlash:[url path]]]];
        }
        
        if (! [url isFileURL]) {
            url = [self rewriteURL:url];
        }
        
        [app openApplicationwWithURL:url];
        
//        [controller setTitle:name];
//        
//        if (! [url isFileURL]) {
//            url = [self rewriteURL:url];
//        }
//        
//        
//        if (baseURL && !noBase) {
//            [controller loadRequest:[NSMutableURLRequest requestWithURL:url] baseURL:baseURL];
//        } else {
//            [controller loadRequest:[NSMutableURLRequest requestWithURL:url]];
//        }
    }
}

- (NitroxWebViewController *) controller {
    @synchronized(self) {
        if (!app) {
//            NitroxWebViewController *wvc = [[NitroxWebViewController alloc] 
//                                            initWithNibName:@"NitroxWebView" bundle:[NSBundle mainBundle]];
//            
//            controller = wvc;

            app = [[NitroxCore singleton] createApp];
            
            [self goHome];
        }
    }
    return [app webViewController];
}

- (void) dealloc {
    [url release];
    [baseURL release];
    [name release];
    [app release];
    [super dealloc];
}

@end
