//
//  NitroxWebViewController.h
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxWebView.h"
#import "NitroxHTTP.h"
#import "NitroxHTTPServer.h"
#import "NitroxRPCCallback.h"

@protocol NitroxWebViewDelegate;
@class NitroxApp;

@interface NitroxWebViewController : UIViewController <UIWebViewDelegate> {
    NitroxApp*             app;
    
    // properties
    BOOL                   loadJSLib;
    NSArray*               otherJSLibs;
    
    id<NitroxWebViewDelegate>   delegate;
    
    NSString*              webRootPath;
    
    // private
    BOOL                   passNext;

    NitroxHTTPServer*             server;
    id<NitroxHTTPServerDelegate>  serverDelegate;
    NitroxHTTPServerPathDelegate* rpcDelegate;    
    
    int                    httpPort;
    NSString*              authToken;
}

@property (assign) NitroxApp*                   app;
@property (assign) BOOL                         loadJSLib;
@property (readonly) NSInteger                    httpPort;
@property (retain) NSArray*                     otherJSLibs;
@property (assign) id<NitroxWebViewDelegate>    delegate;
@property (retain) NSString*                    webRootPath;
@property (retain) NitroxHTTPServerPathDelegate* rpcDelegate;   

- (NitroxWebView*)webView;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadRequest:(NSURLRequest *)request baseURL:(NSURL *)baseURL;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;

- (void)scheduleCallback:(NitroxRPCCallback *)callback;


@end


@protocol NitroxWebViewDelegate <UIWebViewDelegate>


@end
