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

@interface NitroxApp : NSObject {
    // remote directory to load from
    NSString*                     remoteRoot;

    // local directory to load from
    NSString*                     localRoot;
    
    // base URL to use for browser
    NSString*                     baseURL;
    
    // URL to pretend to be under
    NSString*                     masqueradeURL;
    
    id<NitroxWebViewDelegate>     delegate;

    NitroxWebViewController*      webViewController;
}

@end
