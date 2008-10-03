//
//  NSObject+JSBridge.h
//  nitrox
//
//  Created by Robert Sanders on 10/1/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NSObject (JSBridge)

- (NSArray*) instanceMethodNames;
- (NSArray*) classMethodNames;

- (NSString *) serializeToJSON;

@end
