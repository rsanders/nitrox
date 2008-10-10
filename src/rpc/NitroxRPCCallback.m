//
//  NitroxRPCCallback.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/5/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxRPCCallback.h"


@implementation NitroxRPCCallback

@synthesize script;

+ (NitroxRPCCallback *)callbackWithString:(NSString *)jsstring
{
    NitroxRPCCallback *cb = [[NitroxRPCCallback alloc] init];
    cb.script = jsstring;
    return [cb autorelease];
}


- (void) dealloc {
    self.script = Nil;
    [super dealloc];
}

@end
