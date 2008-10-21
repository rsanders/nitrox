//
//  NitroxSymbolTable.h
//  libnitrox
//
//  Created by Robert Sanders on 10/20/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NitroxSymbolTable <NSObject>
// - (id) lookup:(NSString *)key;
@end

@interface NitroxSymbolTable : NSObject <NitroxSymbolTable> {
    NSMutableDictionary*     symbols;
    id<NitroxSymbolTable>    nextTable;
}

@property (retain) id<NitroxSymbolTable>   nextTable;

// designated initializer
- (NitroxSymbolTable*) initWithDictionary:(NSDictionary*)dict;

- (NitroxSymbolTable*) init;

// see KVC for add/set methods


@end
