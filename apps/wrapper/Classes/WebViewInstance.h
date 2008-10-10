//
//  WebViewInstance.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/29/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewInstance : NSObject {
    NSURL*     url;
    NSURL*     baseURL;
    NSString*  name;
    BOOL       noBase;
    
    UIViewController*   controller;
}

@property (readonly)   NSString*          name;
@property (readonly)   UIViewController*  controller;
@property (assign)     BOOL               noBase;

+ (WebViewInstance*) instanceWithURL:(NSURL*)url baseURL:(NSURL*)url name:(NSString *)name;


@end
