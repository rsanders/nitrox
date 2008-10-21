//
//  NitroxSymbolTable.m
//  libnitrox
//
//  Created by Robert Sanders on 10/20/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxSymbolTable.h"


@implementation NitroxSymbolTable

@synthesize nextTable;

- (NitroxSymbolTable*) initWithDictionary:(NSDictionary*)dict
{
    [super init];
    symbols = [[NSMutableDictionary alloc] initWithDictionary:dict];
    nextTable = nil;
    
    return self;
}

- (NitroxSymbolTable*) init
{
    id dict = [[NSDictionary alloc] init];
    id res = [self initWithDictionary:dict];
    [dict release];
    return res;
}

- (void) dealloc 
{
    [symbols release];
    [nextTable release];
    [super dealloc];
}

#pragma mark KVC Methods

- (id) valueForKey:(NSString *)key
{
    id res = [symbols valueForKey:key];
    if (!res && nextTable) {
        return [(NSObject *)nextTable valueForKey:key]; 
    }

    return res;
}

- (void) setValue:(id)value forKey:(NSString *)key
{
    [symbols setValue:value forKey:key];
}


@end
