//
//  NitroxCore.m
//  libnitrox
//
//  Created by Robert Sanders on 10/15/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxCore.h"
#import "NitroxApp.h"
#import "NitroxHTTPServer.h"
#import "NitroxHTTPServerPathDelegate.h"

static NitroxCore *singleton;

@interface NitroxCore (Private)
- (void) startHTTPServer;
@end

@implementation NitroxCore

@synthesize apps, server, httpPort;

+ (NitroxCore*) singleton
{
    @synchronized (self) {
        if (!singleton) {
            singleton = [[NitroxCore alloc] init];
        }
        
        return singleton;
    }
    
    // shut up, xcode
    return singleton;
}

- (NitroxCore *) init {
    [super init];
    self.apps = [[NSMutableDictionary alloc] init];
    rootPathDelegate = [[NitroxHTTPServerPathDelegate alloc] init];
    self.server = [[NitroxHTTPServer alloc] initWithDelegate:rootPathDelegate];

    NSString *portString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"nitrox_http_port"];
    if (portString) {
        httpPort = [portString intValue];
    } else {
        httpPort = 58214;
    }
    
    [server setPort:httpPort];
    [server setAcceptWithRunLoop:NO];
    [server setLocalhostOnly:YES];
    
    return self;
}

- (NitroxApp*) createApp
{
    NitroxApp *app = [[NitroxApp alloc] initWithCore:self];
    
    [apps setValue:app forKey:[app appID]];
    
    // TODO: save in dictionary
    [appPathDelegate addPath:[app appID] delegate:[app appServerDelegate]];
    
    return app;
}

- (void) start
{
    [self startHTTPServer];
}

- (void) stop
{
    [self.server stop];
}

- (void) dealloc {
    self.apps = Nil;
    self.server = Nil;
    [appPathDelegate release];
    [rootPathDelegate release];
    [super dealloc];
}

- (void) startHTTPServer {
    
    // fallback is an authoritative filesystem server rooted at APP.app/web
    [rootPathDelegate setDefaultDelegate:
     [[[NitroxHTTPServerFilesystemDelegate alloc] 
       initWithRoot:[NSString stringWithFormat:@"%@/web",
                     [[NSBundle mainBundle] bundlePath]]
       authoritative:YES] 
      autorelease]];
    
    appPathDelegate = [[NitroxHTTPServerPathDelegate alloc] init];
    [rootPathDelegate addPath:@"_app" delegate:appPathDelegate];

    [rootPathDelegate addPath:@"log" delegate:[NitroxHTTPServerLogDelegate singleton]];
    
    [rootPathDelegate addPath:@"proxy" delegate:[[[NitroxHTTPServerProxyDelegate alloc] init] autorelease]];

    NSError *error;
    [self.server start:&error];
}


@end
