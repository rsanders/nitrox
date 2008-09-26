//
//  NibwareWebViewController.h
//  pingle
//
//  Created by Robert Sanders on 9/23/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NibwareWebViewDelegate;

@interface NibwareWebViewController : UIViewController <UIWebViewDelegate> {
    BOOL loadJSLib;
    NSArray *otherJSLibs;
    
    // remapping
    BOOL passNext;
    
    
    id<NibwareWebViewDelegate>   delegate;
    
}

@property (assign) BOOL                         loadJSLib;
@property (retain) NSArray*                     otherJSLibs;
@property (assign) id<NibwareWebViewDelegate>   delegate;

@end


@protocol NibwareWebViewDelegate <UIWebViewDelegate>


@end