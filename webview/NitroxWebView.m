//
//  NitroxWebView.m
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxWebView.h"

#import "NitroxApiDirectSystem.h"

@implementation NitroxWebView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}

#pragma mark Undocumented / Private methods

// DOES NOT WORK
- (void)webView:(id)webView addMessageToConsole:(id)dictionary
{
    NSLog(@"adding message to console: %@", dictionary);
}

// DOES NOT WORK
- (void) _reportError:(id)error
{
    NSLog(@"reporting error: %@", error);
}

// WORKS
//- (void)webView:(id)webView runJavaScriptAlertPanelWithMessage:(id)message initiatedByFrame:(id)frame
//{
//    NSLog(@"got alert panel on webview %@: %@", webView, message);
//    if ([super respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:)]) {
//        NSLog(@"NEVER MIND, not sending alert panel msg to super");
//        // [super webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame];
//    }
//}

- (void)webView:(id)webView windowScriptObjectAvailable:(id)windowScriptObject {
    NSLog(@"%@ received readiness %@", self, NSStringFromSelector(_cmd));
    
    /* here we'll add our object to the window object as an object named
     'nadirect'.  We can use this object in JavaScript by referencing the 'nadirect'
     property of the 'window' object.   */

    NSLog(@"scriptObject is %@", windowScriptObject);
    [windowScriptObject setValue:[[NitroxApiDirectSystem alloc] init] forKey:@"nadirect"];
}

// UNKNOWN
- (void)webView:(id)webView unableToImplementPolicyWithError:(id)error frame:(id)frame
{
    NSLog(@"unable to implement policy with error: %@", error);
}

@end
