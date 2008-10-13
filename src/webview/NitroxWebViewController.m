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

@interface NitroxWebViewController (Private) 
- (void)startHTTPServer;
@end


@implementation NitroxWebViewController

@synthesize loadJSLib, otherJSLibs, delegate, webRootPath, httpPort, rpcDelegate;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    id ret = [super initWithNibName:nibName bundle:nibBundle];

    passNext = NO;
    loadJSLib = YES;
    [self startHTTPServer];

    return ret;
}

- (void) stop {
    [server stop];
}

- (void)startHTTPServer {
    if (server) {
        NSLog(@"server already started on port %d", self.httpPort);
        return;
    }

    NSLog(@"starting HTTP server");
    
    NitroxHTTPServerPathDelegate *pathDelegate = [[NitroxHTTPServerPathDelegate alloc] init];
    [pathDelegate addPath:@"log" delegate:[NitroxHTTPServerLogDelegate singleton]];

    [pathDelegate addPath:@"proxy" delegate:[[[NitroxHTTPServerProxyDelegate alloc] init] autorelease]];
    
    rpcDelegate = [[NitroxHTTPServerPathDelegate alloc] init];
    [pathDelegate addPath:@"rpc" delegate:rpcDelegate];
    
    [rpcDelegate addPath:@"Device" delegate:[[NitroxRPCDispatcher alloc] 
                                             initWithStubClass:[[NitroxApiDevice alloc] init]
                                             webViewController:self]];

    [rpcDelegate addPath:@"Location" delegate:[[NitroxRPCDispatcher alloc] 
                                               initWithStubClass:[[NitroxApiLocation alloc] init]
                                               webViewController:self]];


    [rpcDelegate addPath:@"Accelerometer" delegate:[[NitroxRPCDispatcher alloc] 
                                                    initWithStubClass:[[NitroxApiAccelerometer alloc] init]
                                                    webViewController:self]];
    
    [rpcDelegate addPath:@"Vibrate" delegate:[[NitroxRPCDispatcher alloc] 
                                              initWithStubClass:[[NitroxApiVibrate alloc] init]
                                              webViewController:self]];

    [rpcDelegate addPath:@"Benchmark" delegate:[[NitroxRPCDispatcher alloc] 
                                              initWithStubClass:[[NitroxApiBenchmark alloc] init]
                                              webViewController:self]];

    [rpcDelegate addPath:@"System" delegate:[[NitroxRPCDispatcher alloc] 
                                              initWithStubClass:[[NitroxApiSystem alloc] init]
                                              webViewController:self]];

    [rpcDelegate addPath:@"Event" delegate:[[NitroxRPCDispatcher alloc] 
                                             initWithStubClass:[[NitroxApiEvent alloc] init]
                                             webViewController:self]];

    [rpcDelegate addPath:@"Application" delegate:[[NitroxRPCDispatcher alloc] 
                                            initWithStubClass:[[NitroxApiApplication alloc] init]
                                            webViewController:self]];

    NitroxApiPhoto *photo = [[NitroxApiPhoto alloc] init];
    [rpcDelegate addPath:@"Photo" delegate:[[NitroxRPCDispatcher alloc] 
                                            initWithStubClass:photo
                                            webViewController:self]];
    
    [pathDelegate addPath:@"photoresults" delegate:
     [[NitroxHTTPServerFilesystemDelegate alloc] 
       initWithRoot:photo.saveDir
       authoritative:YES]
     ];
    
    // fallback is an authoritative filesystem server rooted at APP.app/web
    [pathDelegate setDefaultDelegate:
        [[[NitroxHTTPServerFilesystemDelegate alloc] 
            initWithRoot:[NSString stringWithFormat:@"%@/web",
                          [[NSBundle mainBundle] bundlePath]]
            authoritative:YES] 
         autorelease]];
    
    serverDelegate = pathDelegate;

    server = [[NitroxHTTPServer alloc] initWithDelegate:serverDelegate];
    
    // TODO: randomize 
    authToken = @"temptoken";
    
    httpPort = 58214;
    if (httpPort > 0) {
        [server setPort:httpPort];
    }
    
    // if you say YES here, you gots yourself a deadlock
    [server setAcceptWithRunLoop:NO];
    
    // security risk otherwise; once we validate with tokens, it won't be as much, though
    // it's still kind of useless unless we want to allow distributed communication / RPC
    [server setLocalhostOnly:YES];

    NSError *error;
    [server start:&error];
    
    if (error) {
        NSLog(@"had error starting HTTP server: %@", error);
        @throw error;
    }
    
    httpPort = [server port];
    NSLog(@"started HTTP server %d", httpPort);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [(UIWebView*)self.view setDelegate:self];

    [self startHTTPServer];
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
    otherJSLibs = Nil;
    
    [server stop];
    [server release];
    
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
                          "alert('no runny');"                              
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

- (void)insertJavascriptString:(NSString *)script {
    NSLog(@"inserting JS: %@", [script substringToIndex:80]);
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
    return Nil;
}

- (BOOL)handleJSLog:(UIWebView *)webView request:(NSURLRequest *)request 
      navigationType:(UIWebViewNavigationType)navigationType 
{
    NSString *msg = [[request.URL query]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"WEB LOG: %@", msg);
    
    // doesn't do anything useful
    // [(NSMutableURLRequest *)request setURL:[NSURL URLWithString:@"http://localhost:58214/foobar.html"]];
    
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
        return YES;
    } 

    // TODO: use remapping delegate
    NSURL *remapping = Nil;
    
    if (remapping != Nil) {
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

    NSString *nitroxInfo = [NSString stringWithFormat:
                            @"_nitrox_info = {port: %d, baseurl: 'http://127.0.0.1:%d/rpc', enabled: true, methods:['ajax']};\n"
                            "if (Nitrox && Nitrox.Runtime) { Nitrox.Runtime.port = %d; Nitrox.Runtime.enabled = true; }",
                            self.httpPort, self.httpPort, self.httpPort];
    
    
    [self insertJavascriptString:nitroxInfo];
    
    if (loadJSLib && false) {
        NSLog(@"loading JSlib");
        
        NSString *jspath = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js" inDirectory:@"web/lib"];
        [self insertJavascriptByURL:[NSURL fileURLWithPath:jspath] asReference:NO];

        jspath = [[NSBundle mainBundle] pathForResource:@"nitrox" ofType:@"js" inDirectory:@"web/lib"];
        [self insertJavascriptByURL:[NSURL fileURLWithPath:jspath] asReference:NO];
    }

    NSLog(@"inserted configuration info");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"wVDFL");
    

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

    /* 
     * this doesn't seem to affect JS same origin policy at all 
     */
//    NSURL *baseURL = [self createBaseURL];
//    NSLog(@"in loadREquest, baseURL = %@", baseURL);
//    [realRequest setMainDocumentURL:baseURL];

    //[[self webView] loadRequest:realRequest];
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

