//
//  NitroxScriptDebugDelegate.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/10/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxScriptDebugDelegate.h"


@implementation NitroxScriptDebugDelegate

/*
 WebScriptCallFrame methods:

 32f5add0 t -[WebResourcePrivate dealloc]
 32f80b30 t -[WebScriptCallFrame caller]
 32f80a60 t -[WebScriptCallFrame dealloc]
 32f80c00 t -[WebScriptCallFrame evaluateWebScript:]
 32f80bd0 t -[WebScriptCallFrame exception]
 32f80ba0 t -[WebScriptCallFrame functionName]
 32f80b70 t -[WebScriptCallFrame scopeChain]
 32f80ac0 t -[WebScriptCallFrame setUserInfo:]
 32f80b20 t -[WebScriptCallFrame userInfo]

 
 00017 - (void)dealloc;
 00018 - (void)setUserInfo:(id)fp8;
 00019 - (id)userInfo;
 00020 - (id)caller;
 00021 - (id)scopeChain;
 00022 - (id)functionName;
 00023 - (id)exception;
*/

// some source was parsed, establishing a "source ID" (>= 0) for future reference
// this delegate method is deprecated, please switch to the new version below
//- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
//        fromURL:(NSString *)url
//       sourceId:(int)sid
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called didParseSource; sid=%d, url=%@", sid, url);
//}

// some source was parsed, establishing a "source ID" (>= 0) for future reference
- (void)webView:(WebView *)webView       didParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
       sourceId:(int)sid
    forWebFrame:(WebFrame *)webFrame
{
    NSLog(@"NSDD: called didParseSource: sid=%d, url=%@", sid, url);
}

// some source failed to parse
- (void)webView:(WebView *)webView  failedToParseSource:(NSString *)source
 baseLineNumber:(unsigned)lineNumber
        fromURL:(NSURL *)url
      withError:(NSError *)error
    forWebFrame:(WebFrame *)webFrame
{
    NSLog(@"NSDD: called failedToParseSource: url=%@ line=%d error=%@\nsource=%@", url, lineNumber, error, source);

}

// just entered a stack frame (i.e. called a function, or started global scope)
//- (void)webView:(WebView *)webView    didEnterCallFrame:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called didEnterCallFrame");
//}

// about to execute some code
//- (void)webView:(WebView *)webView willExecuteStatement:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called willEXecuteStatement");
//}

// about to leave a stack frame (i.e. return from a function)
//- (void)webView:(WebView *)webView   willLeaveCallFrame:(WebScriptCallFrame *)frame
//       sourceId:(int)sid
//           line:(int)lineno
//    forWebFrame:(WebFrame *)webFrame
//{
//    NSLog(@"NSDD: called willLeaveCallFrame");
//}

// exception is being thrown
- (void)webView:(WebView *)webView   exceptionWasRaised:(WebScriptCallFrame *)frame
       sourceId:(int)sid
           line:(int)lineno
    forWebFrame:(WebFrame *)webFrame
{
    NSLog(@"NSDD: exception: sid=%d line=%d function=%@, caller=%@, exception=%@", 
          sid, lineno, [frame functionName], [frame caller], [frame exception]);
}

@end
