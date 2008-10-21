//
//  NitroxClassSymbolTable.m
//  libnitrox
//
//  Created by Robert Sanders on 10/21/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxClassSymbolTable.h"


@implementation NitroxClassSymbolTable

/*
 * Do the usual thing, but if that fails, look in the global class namespace
 *
 */
- (id) valueForKey:(NSString *)key
{
    id res = [super valueForKey:key];
    if (!res) {
        res = NSClassFromString(key);
    }
    
    return res;
}

@end
