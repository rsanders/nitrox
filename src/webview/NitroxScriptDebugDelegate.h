//
//  NitroxScriptDebugDelegate.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/10/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WebScriptDebugDelegate;
@class WebFrame;
@class WebView;
@class WebScriptCallFrame;

@interface NitroxScriptDebugSourceInfo : NSObject {
    NSInteger    lineNumber;
    NSString*    url;
    NSString*    body;
    NSInteger    sid;
}

@property (assign) NSInteger lineNumber;
@property (retain) NSString *url;
@property (retain) NSString *body;
@property (assign) NSInteger sid;


- (NSString *) description;
- (NitroxScriptDebugSourceInfo*) initWithURL:(NSString *)url
                                        body:(NSString *)body
                                         sid:(NSInteger)sid
                                  lineNumber:(NSInteger)line;

@end



@interface NitroxScriptDebugDelegate : NSObject <WebScriptDebugDelegate> {
    NSMutableDictionary*       sources;
}

/*
 * See http://trac.webkit.org/wiki/Drosera
 *
 */ 

// some source was parsed, establishing a "source ID" (>= 0) for future reference
// this delegate method is deprecated, please switch to the new version below
//- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
//        fromURL:(NSString *)url
//       sourceId:(int)sid
//    forWebFrame:(WebFrame *)webFrame;

// some source was parsed, establishing a "source ID" (>= 0) for future reference
- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
       sourceId:(int)sid
    forWebFrame:(WebFrame *)webFrame;

// some source failed to parse
- (void)webView:(WebView *)webView  failedToParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
      withError:(NSError *)error
    forWebFrame:(WebFrame *)webFrame;

// just entered a stack frame (i.e. called a function, or started global scope)
//- (void)webView:(WebView *)webView    didEnterCallFrame:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame;

// about to execute some code
//- (void)webView:(WebView *)webView willExecuteStatement:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame;

// about to leave a stack frame (i.e. return from a function)
//- (void)webView:(WebView *)webView   willLeaveCallFrame:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame;

// exception is being thrown
- (void)webView:(WebView *)webView   exceptionWasRaised:(WebScriptCallFrame *)frame
       sourceId:(int)sid
           line:(int)lineno
    forWebFrame:(WebFrame *)webFrame;


@end
