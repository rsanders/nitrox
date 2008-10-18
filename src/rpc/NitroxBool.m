//
//  NitroxBool.m
//  libnitrox
//
//  Created by Robert Sanders on 10/17/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxBool.h"

static NitroxBool *trueObject;
static NitroxBool *falseObject;

@implementation NitroxBool

+ initialize {
    trueObject = [[NitroxBool alloc] initWithValue:YES];
    falseObject = [[NitroxBool alloc] initWithValue:NO];    
}

+ (NitroxBool*) trueObject {
    return trueObject;
}

+ (NitroxBool*) falseObject {
    return falseObject;
}

+ (NitroxBool*) objectForBool:(BOOL) val
{
    return val ? trueObject : falseObject;
}

- (NitroxBool*) initWithValue:(BOOL) newval {
    [super init];
    val = newval;
    return self;
}

- (NSString *) serializeToJSON {
    return val ? @"true" : @"false";
}

- (BOOL) boolValue {
    return val;
}


@end
