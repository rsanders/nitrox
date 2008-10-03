//
//  NitroxWebViewController.m
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxWebViewController.h"
#import "NitroxWebView.h"
#import "NitroxHTTP.h"

#import "Nibware.h"

@interface NitroxWebViewController (Private) 
- (void)startHTTPServer;
@end


@implementation NitroxWebViewController

@synthesize loadJSLib, otherJSLibs, delegate, webRootPath, httpPort;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    id ret = [super initWithNibName:nibName bundle:nibBundle];

    passNext = NO;
    loadJSLib = YES;
    [self startHTTPServer];

    return ret;
}

- (void)startHTTPServer {
    if (server) {
        NSLog(@"server already started on port %d", [server port]);
        return;
    }

    NSLog(@"starting HTTP server");
    
    NitroxHTTPServerPathDelegate *pathDelegate = [[NitroxHTTPServerPathDelegate alloc] init];
    [pathDelegate addPath:@"log" delegate:[NitroxHTTPServerLogDelegate singleton]];

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
    
    NSLog(@"inserting JS from URL %@: %@", url, jsstring);
    [[self webView] stringByEvaluatingJavaScriptFromString:jsstring];
}

- (void)insertJavascriptFile:(NSString *)path {
    [self insertJavascriptByURL:[NSURL fileURLWithPath:path] asReference:NO];
}

- (void)insertJavascriptString:(NSString *)script {
    NSLog(@"inserting JS: %@", script);
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

- (id)handleJSLog:(UIWebView *)webView request:(NSURLRequest *)request 
      navigationType:(UIWebViewNavigationType)navigationType 
{
    NSString *msg = [[request.URL query]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"WEB LOG: %@", msg);
    
    return Nil;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType 
{
    NSLog(@"wVsSLWR, req=%@", request);

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
        [self handleJSLog:webView request:request navigationType:navigationType];

        return NO;
    }
    
    // if we're remapping, we'll want the remapped URL to pass through unmolested
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
    if (loadJSLib || true) {
        NSLog(@"loading JSlib");
        
        NSString *jspath = [[NSBundle mainBundle] pathForResource:@"jquery" ofType:@"js" inDirectory:@"web/lib"];
        [self insertJavascriptByURL:[NSURL fileURLWithPath:jspath] asReference:NO];

        jspath = [[NSBundle mainBundle] pathForResource:@"nitrox" ofType:@"js" inDirectory:@"web/lib"];
        [self insertJavascriptByURL:[NSURL fileURLWithPath:jspath] asReference:NO];
        
        jspath = [[NSBundle mainBundle] pathForResource:@"rew" ofType:@"js" inDirectory:@"web"];
        [self insertJavascriptByURL:[NSURL fileURLWithPath:jspath] asReference:NO];
    }
    
    NSString *nitroxInfo = [NSString stringWithFormat:
                            @"_nitrox_info = {port: %d, enabled: true};\n"
                             "Nitrox.Runtime.port = %d; Nitrox.Runtime.enabled = true;",
                            self.httpPort, self.httpPort];
    
    [self insertJavascriptString:nitroxInfo];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"wVDFL");

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"wVdFLWE: %@", error);
}

#pragma mark UIWebView passthrough

- (NSURL *)createBaseURL {
    return [NSURL URLWithString:
            [NSString stringWithFormat:@"http://localhost:%d/", self.httpPort]];
}

- (void)loadRequest:(NSURLRequest *)request {
    NSMutableURLRequest* realRequest = [request mutableCopy];
    NSURL *baseURL = [self createBaseURL];
#pragma unused (baseURL)

    [realRequest setMainDocumentURL:[self createBaseURL]];

    [[self webView] loadRequest:request];
}

- (void)loadRequest:(NSURLRequest *)request baseURL:(NSURL *)baseURL {
    NSURLResponse *response;
    NSError *error;
    
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

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
    [[self webView] loadHTMLString:string baseURL:baseURL];
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType 
    textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL
{
    [[self webView] loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
}



@end

