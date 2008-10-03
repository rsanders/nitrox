//
//  NitroxHTTPServerFilesystemDelegate.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxHTTPServer.h"

@interface NitroxHTTPServerFilesystemDelegate : NSObject <NitroxHTTPServerDelegate> {
    NSString*                      root;
    BOOL                           authoritative;
    
}

@property (retain)  NSString*                     root;
@property (assign)  BOOL                          authoritative;

- (NitroxHTTPServerFilesystemDelegate *) initWithRoot:(NSString *)path authoritative:(BOOL)isauth;

@end
