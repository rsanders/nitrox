//
//  NitroxWebView.h
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxScriptDebugDelegate.h"

@class WebView;
@class WebInspector;

@interface NitroxWebView : UIWebView {
    WebView*      privateWebView;
    id            windowScriptObject;
    BOOL          scriptDebuggingEnabled;
}

@property BOOL scriptDebuggingEnabled;

@end
