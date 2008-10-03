//
//  NitroxHTTPServerLogDelegate.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NitroxHTTPServer.h"


@interface NitroxHTTPServerLogDelegate : NSObject <NitroxHTTPServerDelegate> {

}

+ (NitroxHTTPServerLogDelegate *) singleton;
- (NitroxHTTPServerLogDelegate *) init;

@end
