//
//  NitroxApiSystem.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"

@interface NitroxApiSystem : NitroxStubClass {
    
}

- (NitroxApiSystem *)init;

// callable args

- (id) openURL:(NSDictionary *)args;
- (id) exit:(NSDictionary *)args;


@end
