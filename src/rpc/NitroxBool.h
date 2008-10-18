//
//  NitroxBool.h
//  libnitrox
//
//  Created by Robert Sanders on 10/17/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NitroxBool : NSObject {
    BOOL val;
}

+ (NitroxBool*) trueObject;
+ (NitroxBool*) falseObject;
+ (NitroxBool*) objectForBool:(BOOL) val;

- (NitroxBool*) initWithValue:(BOOL) val;
- (NSString *) serializeToJson;
- (BOOL) boolValue;


@end
