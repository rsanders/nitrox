//
//  NitroxWebViewController.m
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxWebViewController.h"
#import "NitroxWebView.h"

#import "Nibware.h"


@implementation NitroxWebViewController

@synthesize loadJSLib, otherJSLibs, delegate, webRootPath;

- (void) init {
    [super init];
    passNext = NO;
    loadJSLib = YES;
}

- (void)startHTTPServer {
    NSLog(@"starting HTTP server");    
    server = [[NitroxHTTPServer alloc] initWithDelegate:self];
    
    // TODO: randomize 
    authToken = @"temptoken";
    
    [server setPort:61607];

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
    
    [super dealloc];
}

- (NitroxWebView *)webView {
    return (NitroxWebView*)self.view;
}

#pragma mark NitroxHTTPServer delegate

- (GTMHTTPResponseMessage *)httpServer:(GTMHTTPServer *)server
                         handleRequest:(GTMHTTPRequestMessage *)request
{
    NSLog(@"got request %@", request);
    

    NSString *path = [[request URL] path];

    path = [NSString stringWithFormat:@"%@/web%@",
            [[NSBundle mainBundle] bundlePath],
            path];
    
    NSLog(@"calculated file path is %@", path);
    
    GTMHTTPResponseMessage* message;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager isReadableFileAtPath:path]) {
        NSString *contents = [NSString stringWithContentsOfFile:path];
        message = [GTMHTTPResponseMessage responseWithHTMLString:contents];
    } else {
        message = [GTMHTTPResponseMessage emptyResponseWithCode:404];
    }
    
    return message;
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
    
//    [webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:)
//                                              withObject:jsstring waitUntilDone:NO];
    [webView stringByEvaluatingJavaScriptFromString:jsstring];
    return Nil;
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType 
{
    NSLog(@"wVsSLWR, req=%@", request);

    // handle special internal URLs here
    
    if ([[request.URL scheme] isEqualToString:@"nibwarejsbridge"]
        || [[request.URL host] isEqualToString:@"nibwarejsbridge"]) {
        [self handleJSBridge:webView request:request navigationType:navigationType];
        
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
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"wVDFL");
    if (loadJSLib || true) {
        NSLog(@"loading JSlib");
        
        NSString *jspath = [[NSBundle mainBundle] pathForResource:@"rew" ofType:@"js" inDirectory:@"web"];
        
        [self insertJavascriptByURL:[NSURL fileURLWithPath:jspath] asReference:NO];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"wVdFLWE: %@", error);
}

#pragma mark NitroxWebViewDelegate

@end

