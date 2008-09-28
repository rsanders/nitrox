//
//  NitroxAppPage.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/28/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxApp.h"

@class NitroxApp;

@interface NitroxAppPage : NSObject {
    NSDictionary*                  objectMap;

    NSURL*                         realURL;
    NSURL*                         effectiveURL;
    NSURL*                         baseURL;
    
    // parent pointers, not retained or released
    NitroxApp*                     app;
    NitroxWebView*                 view;
}

@property (assign,readonly)  NitroxApp*          app;
@property (assign,readonly)  NitroxWebView*      view;


@end
