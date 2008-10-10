//
//  NitroxHTTPServerPathDelegate.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/28/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxHTTPServer.h"

@interface NitroxHTTPServerPathDelegate : NSObject <NitroxHTTPServerDelegate> {
    NSMutableDictionary*           paths;
    id<NitroxHTTPServerDelegate>   defaultDelegate;

}

@property (retain)  NSDictionary*                 paths;
@property (retain)  id<NitroxHTTPServerDelegate>  defaultDelegate;

- (NitroxHTTPServerPathDelegate *) init;
- (void) addPath:(NSString *)path delegate:(id<NitroxHTTPServerDelegate>)delegate;

@end
