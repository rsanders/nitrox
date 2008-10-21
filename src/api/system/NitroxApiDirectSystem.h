//
//  NitroxApiDirectSystem.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/6/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NitroxApp;

@interface NitroxApiDirectSystem : NSObject {
    NitroxApp *app;
    NSString *attr;
}

- (NitroxApiDirectSystem*)initWithApp:(NitroxApp*)app;

- (NSString *) model;
- (void) log:(NSString *)msg;

- (NSString *) getKey:(NSString *)key fromDictionary:(id)dict;

@property (retain) NSString *attr;

@end
