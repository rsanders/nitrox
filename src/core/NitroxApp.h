//
//  NitroxApp.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/27/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxWebView.h"
#import "NitroxWebViewController.h"
#import "NitroxAppPage.h"

@class NitroxAppPage;
@class NitroxCore;
@protocol NitroxHTTPServerDelegate;

@interface NitroxApp : NSObject {
    NSString*                     appID;
    
    UIView*                       parentView;

    // local directory to load from
    NSString*                     localRoot;
    
    // base URL to use for browser
    NSURL*                        homeURL;

    id<NitroxWebViewDelegate>     delegate;

    NitroxWebViewController*      webViewController;
    
    NitroxAppPage*                currentPage;
    
    NSArray*                      pages;
    
    // not retained
    NitroxCore*                   core;
    
    id<NitroxHTTPServerDelegate>  appServerDelegate;
    NitroxHTTPServerPathDelegate* rpcDelegate;

}

@property (retain) NSString*                     appID;
@property (retain) UIView*                       parentView;
@property (retain) NSString*                     localRoot;
@property (retain) NSURL*                        homeURL;
@property (retain) id<NitroxWebViewDelegate>     delegate;
@property (retain) NitroxWebViewController*      webViewController;
@property (retain) NitroxAppPage*                currentPage;
@property (retain) NSArray*                      pages;

@property (readonly) id<NitroxHTTPServerDelegate>     appServerDelegate;

- (NitroxApp*) initWithCore:(NitroxCore*)core;

- (void) openApplication:(NSString *)ref;
- (void) openApplicationwWithURL:(NSURL *)url;

- (NSURL *) convertToUrl:(NSString *)ref;

@end
