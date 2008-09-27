//
//  NitroxyWebViewController.h
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxyWebView.h"
#import "NitroxyHTTPServer.h"

@protocol NitroxyWebViewDelegate;

@interface NitroxyWebViewController : UIViewController <UIWebViewDelegate> {
    // properties
    BOOL                   loadJSLib;
    NSArray*               otherJSLibs;
    
    id<NitroxyWebViewDelegate>   delegate;
    
    NSString*              webRootPath;
    
    // private
    BOOL                   passNext;
    NitroxyHTTPServer*     server;
    
    int                    httpPort;
    NSString*              authToken;
}

@property (assign) BOOL                         loadJSLib;
@property (retain) NSArray*                     otherJSLibs;
@property (assign) id<NitroxyWebViewDelegate>   delegate;
@property (retain) NSString*                    webRootPath;

- (NitroxyWebView*)webView;

@end


@protocol NitroxyWebViewDelegate <UIWebViewDelegate>


@end
