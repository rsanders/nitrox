//
//  NitroxWebView.m
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxWebView.h"
#import "NitroxScriptDebugDelegate.h"
#import "NitroxApiDirectSystem.h"
#import "NitroxApp.h"

@implementation NitroxWebView

@synthesize scriptDebuggingEnabled;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    scriptDebuggingEnabled = NO;
    return self;
}

- (void)setApp:(NitroxApp*)newapp {
    app = newapp;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}

- (void) setScriptDebuggingEnabled:(BOOL)val 
{
    scriptDebuggingEnabled = val;
    if (privateWebView) {
        if (val) {
            [privateWebView setScriptDebugDelegate:[[NitroxScriptDebugDelegate alloc] init]];
        } else {
            [privateWebView setScriptDebugDelegate:nil];
        }
    }
}

#pragma mark Undocumented / Private methods

// never seems to get called
- (void)webView:(id)webView addMessageToConsole:(NSDictionary *)dictionary
{
    NSLog(@"adding message to console: %@", dictionary);
}

// never seems to get called
- (void) _reportError:(id)error
{
    NSLog(@"reporting error: %@", error);
}

#if TARGET_IPHONE_SIMULATOR
#  ifndef IPHONE_SDK_KOSHER

// TODO: the following two methods should be synchronous, and not return until
//   the user has interacted with the UI.

// Javascript alerts
- (void) webView: (WebView*)webView runJavaScriptAlertPanelWithMessage: (NSString*)message 
    initiatedByFrame: (WebFrame*)frame
{
    NSLog(@"Javascript Alert: %@", message);
    
    UIAlertView *alertSheet = [[UIAlertView alloc] init];
    [alertSheet setTitle: @"Javascript Alert"];
    [alertSheet addButtonWithTitle: @"OK"];
    [alertSheet setMessage:message];
    [alertSheet setDelegate: self];
    [alertSheet show];
}

- (BOOL) webView: (WebView*)webView runJavaScriptConfirmPanelWithMessage: (NSString*)message 
    initiatedByFrame: (WebFrame*)frame
{
    NSLog(@"Javascript Alert: %@", message);
    
    UIAlertView *alertSheet = [[UIAlertView alloc] init];
    [alertSheet setTitle: @"Javascript Alert"];
    [alertSheet addButtonWithTitle: @"OK"];
    [alertSheet addButtonWithTitle: @"Cancel"];    
    [alertSheet setMessage:message];
    [alertSheet setDelegate: self];
    [alertSheet show];
    return YES;
}

#  endif  // IPHONE_SDK_KOSHER
#endif // TARGET_IPHONE_SIMULATOR

// // GETS called, but the call to [super ...] fails. Which is weird, because it shows up in the
// // UIKit dylib
//- (void)webView:(id)webView runJavaScriptAlertPanelWithMessage:(id)message initiatedByFrame:(id)frame
//{
//    NSLog(@"got alert panel on webview %@: %@", webView, message);
//    // this doesn't work either; the respondsToSelector check passes, but the app crashes
//    if ([super respondsToSelector:@selector(webView:runJavaScriptAlertPanelWithMessage:initiatedByFrame:)]) {
//        NSLog(@"NEVER MIND, not sending alert panel msg to super");
//        // [super webView:webView runJavaScriptAlertPanelWithMessage:message initiatedByFrame:frame];
//    }
//}

//- (BOOL) webView:(id)webView runJavaScriptConfirmPanelWithMessage:(id)message initiatedByFrame:(id)frame
//{
//    NSLog(@"got confirm panel with message: %@", message);
//    // XXX: for some reason if we call super here, we get a crash.  but if we don't
//    //     override this method, it executes!
//    [super webView:webView runJavaScriptConfirmPanelWithmessage:message initiatedByFrame:frame];
//    sleep(3);
//    return YES;
//}

//- (NSString *)webView:(WebView *)sender runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt 
//          defaultText:(NSString *)defaultText initiatedByFrame:(WebFrame *)frame;
//{
//    NSLog(@"got javascript text input panel with prompt %@", prompt);
//    // XXX: for some reason if we call super here, we get a crash.  but if we don't
//    //     override this method, it executes!
//    NSString *res = [super webView:sender runJavaScriptTextInputPanelWithPrompt:prompt 
//                       defaultText:defaultText
//                  initiatedByFrame:frame];
//
//    return res;
//}

- (void)webView:(id)webView windowScriptObjectAvailable:(id)newWindowScriptObject {
    NSLog(@"%@ received window ScriptObject %@", self, NSStringFromSelector(_cmd));

    // save these goodies
    windowScriptObject = newWindowScriptObject;
    privateWebView = webView;

    // enact any latent debugging settings
    [self setScriptDebuggingEnabled:scriptDebuggingEnabled];

    /* here we'll add our object to the window object as an object named
     'nadirect'.  We can use this object in JavaScript by referencing the 'nadirect'
     property of the 'window' object.   */

    NSLog(@"scriptObject is %@", windowScriptObject);
    [windowScriptObject setValue:[[NitroxApiDirectSystem alloc] initWithApp:app] forKey:@"nadirect"];
}

// UNKNOWN
- (void)webView:(id)webView unableToImplementPolicyWithError:(id)error frame:(id)frame
{
    NSLog(@"webview=%@, webframe=%@ unable to implement policy with error: %@", 
          webView, frame, error);
}

@end
