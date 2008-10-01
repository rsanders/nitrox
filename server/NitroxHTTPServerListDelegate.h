//
//  NitroxHTTPServerListDelegate.h
//  nitroxy1
//
//  Created by Robert Sanders on 9/30/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "NitroxHTTPServer.h"

@interface NitroxHTTPServerListDelegate : NSObject <NitroxHTTPServerDelegate> {
    NSMutableArray*            list;
}

@property (retain)  NSMutableArray*      list;

- (NitroxHTTPServerListDelegate *) init;
- (void) addDelegate:(id<NitroxHTTPServerDelegate>)delegate;
- (void) insertDelegate:(id<NitroxHTTPServerDelegate>)delegate atIndex:(NSInteger)index;

@end
