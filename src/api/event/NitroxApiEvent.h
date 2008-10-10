//
//  NitroxApiEvent.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"

@interface NitroxApiEvent : NitroxStubClass {
    
}

- (NitroxApiEvent *)init;

// callable args

- (id) addNotificationListener:(NSDictionary *)args;
- (id) removeNotificationListener:(NSDictionary *)args;
- (id) postNotification:(NSDictionary *)args;

@end
