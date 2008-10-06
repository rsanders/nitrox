//
//  NitroxApiDirectSystem.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/6/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NitroxApiDirectSystem : NSObject {
    NSString *attr;
}

- (NSString *) model;
- (void) log:(NSString *)msg;

- (NSString *) getKey:(NSString *)key fromDictionary:(NSDictionary *)dict;

@property (retain) NSString *attr;

@end
