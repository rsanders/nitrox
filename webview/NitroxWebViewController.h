//
//  NitroxWebViewController.h
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxWebView.h"
#import "NitroxHTTPServer.h"

@protocol NitroxWebViewDelegate;

@interface NitroxWebViewController : UIViewController <UIWebViewDelegate> {
    // properties
    BOOL                   loadJSLib;
    NSArray*               otherJSLibs;
    
    id<NitroxWebViewDelegate>   delegate;
    
    NSString*              webRootPath;
    
    // private
    BOOL                   passNext;
    NitroxHTTPServer*     server;
    
    int                    httpPort;
    NSString*              authToken;
}

@property (assign) BOOL                         loadJSLib;
@property (retain) NSArray*                     otherJSLibs;
@property (assign) id<NitroxWebViewDelegate>   delegate;
@property (retain) NSString*                    webRootPath;

- (NitroxWebView*)webView;

@end


@protocol NitroxWebViewDelegate <UIWebViewDelegate>


@end
