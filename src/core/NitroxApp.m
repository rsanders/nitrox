//
//  NitroxApp.m
//  nitroxy1
//
//  Created by Robert Sanders on 9/27/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxApp.h"
#import "NitroxHTTPUtils.h"
#import "NitroxCore.h"

#import "NitroxWebViewController.h"
#import "NitroxWebView.h"

#import "NitroxApi.h"
#import "NitroxRPC.h"

#import "Nibware.h"

@interface NitroxApp (Private) 
- (id<NitroxHTTPServerDelegate>)createServerDelegate;
@end

@implementation NitroxApp

@synthesize appID, localRoot, homeURL;
@synthesize delegate, webViewController;
@synthesize currentPage, pages, parentView;

- (NitroxApp *) initWithCore:(NitroxCore*)newcore {
    [super init];
    
    core = newcore;

    self.webViewController = [[NitroxWebViewController alloc] 
                                    initWithNibName:@"NitroxWebView" bundle:[NSBundle mainBundle]];
    
    [self.webViewController setApp:self];
    
    appServerDelegate = [self createServerDelegate];
    
    return self;
}

- (void) setParentView:(UIView*)view
{
    [view retain];
    if (parentView) {
        [[webViewController view] removeFromSuperview];
        [parentView release];
    }
    parentView = view;

    // i accidentally the whole view
    [[webViewController view] setFrame:[parentView bounds]];
    [parentView addSubview:[webViewController view]];
}

- (NSString *) appID {
    NSString *id = [NSString stringWithFormat:@"%08x", self];
    return id;
}

- (void) dealloc {
    [super dealloc];
}

- (NSURL *) convertToUrl:(NSString *)ref
{
    NSRange range = [ref rangeOfString:@"://"];
    if (range.length == 0) {
        ref = [NSString stringWithFormat:@"%@/web/%@",
                    [[NSBundle mainBundle] bundlePath],
                    [NitroxHTTPUtils stripLeadingSlash:ref]];
        return [NSURL fileURLWithPath:ref];
    } else {
        return [NSURL URLWithString:ref];
    }
}
    
- (void) openApplication:(NSString *)ref
{
    NSURL *url = [self convertToUrl:ref];
//    NSURL *baseURL =  [NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:58214/%@", 
//                                            [NitroxHTTPUtils stripLeadingSlash:[url path]]]];
    [webViewController loadRequest:[NSURLRequest requestWithURL:url] /* baseURL:baseURL */ ];
}

- (void) openApplicationwWithURL:(NSURL *)url
{
    [webViewController loadRequest:[NSURLRequest requestWithURL:url]];
}

- (id<NitroxHTTPServerDelegate>) appServerDelegate
{
    return appServerDelegate;
}

- (id<NitroxHTTPServerDelegate>)createServerDelegate 
{
    NSLog(@"creating server delegate");
    
    NitroxHTTPServerPathDelegate *pathDelegate = [[NitroxHTTPServerPathDelegate alloc] init];
    [pathDelegate addPath:@"log" delegate:[NitroxHTTPServerLogDelegate singleton]];
    
    [pathDelegate addPath:@"proxy" delegate:[[[NitroxHTTPServerProxyDelegate alloc] init] autorelease]];
    
    rpcDelegate = [[NitroxHTTPServerPathDelegate alloc] init];
    [pathDelegate addPath:@"rpc" delegate:rpcDelegate];
    
    [rpcDelegate addPath:@"Device" delegate:[[NitroxRPCDispatcher alloc] 
                                             initWithStubClass:[[NitroxApiDevice alloc] init]
                                             webViewController:webViewController]];
    
    [rpcDelegate addPath:@"Location" delegate:[[NitroxRPCDispatcher alloc] 
                                               initWithStubClass:[[NitroxApiLocation alloc] init]
                                               webViewController:webViewController]];
    
    
    [rpcDelegate addPath:@"Accelerometer" delegate:[[NitroxRPCDispatcher alloc] 
                                                    initWithStubClass:[[NitroxApiAccelerometer alloc] init]
                                                    webViewController:webViewController]];
    
    [rpcDelegate addPath:@"Vibrate" delegate:[[NitroxRPCDispatcher alloc] 
                                              initWithStubClass:[[NitroxApiVibrate alloc] init]
                                              webViewController:webViewController]];
    
    [rpcDelegate addPath:@"Benchmark" delegate:[[NitroxRPCDispatcher alloc] 
                                                initWithStubClass:[[NitroxApiBenchmark alloc] init]
                                                webViewController:webViewController]];
    
    [rpcDelegate addPath:@"System" delegate:[[NitroxRPCDispatcher alloc] 
                                             initWithStubClass:[[NitroxApiSystem alloc] init]
                                             webViewController:webViewController]];
    
    [rpcDelegate addPath:@"Event" delegate:[[NitroxRPCDispatcher alloc] 
                                            initWithStubClass:[[NitroxApiEvent alloc] init]
                                            webViewController:webViewController]];
    
    [rpcDelegate addPath:@"Application" delegate:[[NitroxRPCDispatcher alloc] 
                                                  initWithStubClass:[[NitroxApiApplication alloc] init]
                                                  webViewController:webViewController]];

    [rpcDelegate addPath:@"File" delegate:[[NitroxRPCDispatcher alloc] 
                                                  initWithStubClass:[[NitroxApiFile alloc] init]
                                                  webViewController:webViewController]];
    
    
    NitroxApiPhoto *photo = [[NitroxApiPhoto alloc] init];
    [rpcDelegate addPath:@"Photo" delegate:[[NitroxRPCDispatcher alloc] 
                                            initWithStubClass:photo
                                            webViewController:webViewController]];
    
    [pathDelegate addPath:@"photoresults" delegate:
     [[NitroxHTTPServerFilesystemDelegate alloc] 
      initWithRoot:photo.saveDir
      authoritative:YES]
     ];
    
//    // fallback is an authoritative filesystem server rooted at APP.app/web
//    [pathDelegate setDefaultDelegate:
//     [[[NitroxHTTPServerFilesystemDelegate alloc] 
//       initWithRoot:[NSString stringWithFormat:@"%@/web",
//                     [[NSBundle mainBundle] bundlePath]]
//       authoritative:YES] 
//      autorelease]];
    
    return pathDelegate;
}

@end
