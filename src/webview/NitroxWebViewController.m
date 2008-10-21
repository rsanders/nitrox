//
//  NitroxWebViewController.m
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxWebViewController.h"
#import "NitroxWebView.h"

#import "NitroxApi.h"
#import "NitroxRPC.h"

#import "Nibware.h"

#import "NitroxApp.h"
#import "NitroxCore.h"

@interface NitroxWebViewController (Private) 
// - (void)startHTTPServer;
@end


@implementation NitroxWebViewController

@synthesize loadJSLib, otherJSLibs, delegate, webRootPath, rpcDelegate, app;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    id ret = [super initWithNibName:nibName bundle:nibBundle];

    passNext = NO;
    loadJSLib = YES;
    // [self startHTTPServer];

    return ret;
}




- (void) stop {
    // [server stop];
}

- (NSInteger) httpPort {
    return 58214;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [(UIWebView*)self.view setDelegate:self];
    [(NitroxWebView*)self.view setApp:app];
    
    // [self startHTTPServer];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    otherJSLibs = nil;
    
    //[server stop];
    //[server release];
    
    [rpcDelegate release];
    [(id<NSObject>)serverDelegate release];

    [super dealloc];
}

- (NitroxWebView *)webView {
    return (NitroxWebView*)self.view;
}

#pragma mark HTML Munging

- (void)insertJavascriptByURL:(NSURL *)url asReference:(BOOL)useRef {
    NSString *jsstring;
    if ([url isFileURL] || useRef) {
        jsstring = [NSString stringWithContentsOfURL:url];
    } else {
        jsstring = [NSString stringWithFormat:
                          @""
                          "(function() {"
                          "  var head = document.getElementsByTagName('head')[0];"
                          "  var script = document.createElement('script');"
                          "  script.setAttribute('type', 'text/javascript');"
                          "  script.setAttribute('src', '%@');"
                          "  head.appendChild(script);"
                          "})();", [url absoluteString]];
    }
    
    NSLog(@"inserting JS from URL %@", url);
    [[self webView] stringByEvaluatingJavaScriptFromString:jsstring];
}

- (void)insertJavascriptFile:(NSString *)path {
    [self insertJavascriptByURL:[NSURL fileURLWithPath:path] asReference:NO];
}

#define MAX_SCRIPT_LENGTH(script) ((script).length <= 80 ? (script).length-1 : 80)

- (void)insertJavascriptString:(NSString *)script {
    NSLog(@"inserting JS: %@", [script substringToIndex:MAX_SCRIPT_LENGTH(script)]);
    [[self webView] stringByEvaluatingJavaScriptFromString:script];
}

#pragma mark JS Bridge

- (id)handleJSBridge:(UIWebView *)webView request:(NSURLRequest *)request 
      navigationType:(UIWebViewNavigationType)navigationType 
{
    NSLog(@"doing js bridge for %@, navtype=%d", request, navigationType);
    
    NSString *jsstring = [NSString stringWithFormat:
        @"bridgecomplete('%@', '%@');",
        @"id not set", [request.URL path]];
    
    [webView stringByEvaluatingJavaScriptFromString:jsstring];
    return nil;
}

- (BOOL)handleJSLog:(UIWebView *)webView request:(NSURLRequest *)request 
      navigationType:(UIWebViewNavigationType)navigationType 
{
    NSString *msg = [[request.URL query]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"WEB LOG: %@", msg);
    return NO;
}

- (void)scheduleCallback:(NitroxRPCCallback *)callback
{
    NSLog(@"scheduling callback: %@", callback.script);
    [self.webView stringByEvaluatingJavaScriptFromString:callback.script];
}

- (BOOL) handleIFRAMERequest:(NSURLRequest *)request
{
    NSLog(@"loading IFRAME from URL %@ into parent document %@",
          [request URL], [request mainDocumentURL]);
    return YES;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType 
{
    NSLog(@"wVsSLWR, req=%@, mainDocURL=%@, navtype=%d", request, [request mainDocumentURL], navigationType);

    // handle special internal URLs here
    
    if ([[request.URL scheme] isEqualToString:@"nibwarejsbridge"]
        || [[request.URL scheme] isEqualToString:@"nitroxbridge"]
        || [[request.URL host] isEqualToString:@"nitroxjsbridge"]
        || [[request.URL host] isEqualToString:@"nibwarejsbridge"]) 
    {
        [self handleJSBridge:webView request:request navigationType:navigationType];
        
        return NO;
    }
    
    if ([[request.URL scheme] isEqualToString:@"nitroxlog"]) {
        return [self handleJSLog:webView request:request navigationType:navigationType];
    }

    // mainDocumentURL is for the enclosing page, URL is the frame URL
    if (navigationType == UIWebViewNavigationTypeOther
        && ! [[request URL] isEqual:[request mainDocumentURL]])
    {
        return [self handleIFRAMERequest:request];
    }
    
    // don't allow direct clicks on links to load; remap them through our loadRequest
    if (navigationType == UIWebViewNavigationTypeLinkClicked || !passNext) {
        [self performSelectorOnMainThread:@selector(loadRequest:)
                                  withObject:[NSURLRequest requestWithURL:[NSURL URLWithString:[request.URL absoluteString]]]
                               waitUntilDone:NO];
        
        return NO;
    }
    
    // if we're remapping, we'll want the remapped URL to pass through unmolested
    // TODO: configurable remapping isn't done yet 
    if (passNext) {
        passNext = NO;
        doRunInit = YES;
        return YES;
    } 

    // TODO: use remapping delegate
    NSURL *remapping = nil;
    
    if (remapping != nil) {
        passNext = YES;
        [webView performSelectorOnMainThread:@selector(loadRequest:)
                              withObject:[NSURLRequest requestWithURL:remapping]
                          waitUntilDone:NO];
    
        return NO;
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"wVDSL");
    passNext = NO;

    /*
     * This is the old way; now we just use <script> tags and load from local HTTP server
     */
    //    if (loadJSLib && false) {
    //        NSLog(@"loading JSlib");
    //        
    //        NSString *jspath = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js" inDirectory:@"web/lib"];
    //        [self insertJavascriptByURL:[NSURL fileURLWithPath:jspath] asReference:NO];
    //
    //        jspath = [[NSBundle mainBundle] pathForResource:@"nitrox" ofType:@"js" inDirectory:@"web/lib"];
    //        [self insertJavascriptByURL:[NSURL fileURLWithPath:jspath] asReference:NO];
    //    }

    //    NSLog(@"inserted configuration info");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"wVDFL");

    // this bit apparently has to run in the finish-load handler, not the start-load,
    // or sometimes (subsequent page loads in the same webview) it doesn't work.
    if (doRunInit) {
        doRunInit = NO;
        NSString *nitroxInfo = [NSString stringWithFormat:
                                @"_nitrox_info = {appid: '%@', port: %d, baseurl: 'http://127.0.0.1:%d/_app/%@/rpc', enabled: true, methods:['ajax']};\n"
                                "if (Nitrox && Nitrox.Runtime) { Nitrox.Runtime.port = %d; Nitrox.Runtime.enabled = true; }"
                                "Nitrox.Runtime.finishedLoading();",
                                [self.app appID], self.httpPort, self.httpPort, [self.app appID], self.httpPort];
        
        [self insertJavascriptString:nitroxInfo];
    }

    passNext = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"wVdFLWE: %@", error);
}

#pragma mark UIWebView passthrough

- (NSURL *)createBaseURL {
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"http://localhost:%d/foo.html", [server port]]];
}

- (void)createNewWebView {
    // only auto-enable debugging on simulator; it's WAY too slow on actual HW
    // also leave disabled for performance testing

#if TARGET_IPHONE_SIMULATOR
#  ifndef PERFORMANCE_TEST
    [[self webView] setScriptDebuggingEnabled:YES];
#  endif
#endif
    return;

    NSLog(@"replacing old webview: %@", self.view);
    NitroxWebView *newWebView = [[NitroxWebView alloc] initWithFrame:self.view.frame];
    [newWebView setDelegate:self];
    UIView *superView = [self.view superview];

    newWebView.hidden = NO;
    newWebView.scalesPageToFit = NO;

    [superView insertSubview:newWebView aboveSubview:self.view];
    [self.view removeFromSuperview];
    
    self.view = newWebView;
    [newWebView release];
    NSLog(@"created new webview: %@", self.view);
}

- (void)loadRequest:(NSURLRequest *)request {
    NSMutableURLRequest* realRequest = [request mutableCopy];

    [self loadRequest:realRequest baseURL:[realRequest URL]];
}

- (void)loadRequest:(NSURLRequest *)request baseURL:(NSURL *)baseURL {
    NSURLResponse *response;
    NSError *error;
    
    NSMutableURLRequest *noCacheRequest = [[request mutableCopy] autorelease];
    [noCacheRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    NSData *data = [NSURLConnection sendSynchronousRequest:noCacheRequest returningResponse:&response error:&error];

    if (!error && data) {
        [self loadData:data MIMEType:[response MIMEType] textEncodingName:[response textEncodingName] baseURL:baseURL];
    } else {
        [self loadHTMLString:[NSString stringWithFormat:
                              @"<html><body>Error: Could not load document from %@, error=%@</body></html>",
                              [request URL], error]
                     baseURL:baseURL];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    [self createNewWebView];

    passNext = YES;
    [[self webView] loadHTMLString:string baseURL:baseURL];
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType 
    textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    [self createNewWebView];

    passNext = YES;
    [[self webView] loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
}

#pragma mark Undocumented / Private methods

// DOES NOT WORK
- (void)webView:(UIWebView *)webView addMessageToConsole:(NSDictionary *)dictionary
{
    NSLog(@"adding message to console in delegate: %@", dictionary);
}


@end

