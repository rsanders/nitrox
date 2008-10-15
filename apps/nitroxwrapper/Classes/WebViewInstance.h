//
//  WebViewInstance.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/29/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NitroxWebViewController;

@interface WebViewInstance : NSObject {
    NSURL*     url;
    NSURL*     baseURL;
    NSString*  name;
    BOOL       noBase;
    
    NitroxWebViewController*   controller;
}

@property (readonly)   NSString*          name;
@property (readonly)   NitroxWebViewController*  controller;
@property (assign)     BOOL               noBase;

+ (WebViewInstance*) instanceWithURL:(NSURL*)url baseURL:(NSURL*)url name:(NSString *)name;

- (void) goHome;

@end
