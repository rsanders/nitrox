//
//  WebViewInstance.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/29/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NitroxWebViewController;
@class NitroxApp;

@interface AppInstance : NSObject {
    NSURL*     url;
    NSURL*     baseURL;
    NSString*  name;
    BOOL       noBase;
    
    // NitroxWebViewController*   controller;
    NitroxApp* app;
}

@property (readonly)   NSString*          name;
@property (readonly)   NitroxWebViewController*  controller;
@property (readonly)   NitroxApp*         app;

@property (assign)     BOOL               noBase;

+ (AppInstance*) instanceWithURL:(NSURL*)url baseURL:(NSURL*)url name:(NSString *)name;

- (void) goHome;

@end
