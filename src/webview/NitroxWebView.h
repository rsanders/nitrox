//
//  NitroxWebView.h
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WebView;
@class WebInspector;

@class NitroxApp;

@interface NitroxWebView : UIWebView {
    WebView*      privateWebView;
    id            windowScriptObject;
    BOOL          scriptDebuggingEnabled;
    NitroxApp*    app;
}

@property BOOL scriptDebuggingEnabled;

- (void)setApp:(NitroxApp*)app;

@end
