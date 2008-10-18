//
//  NitroxBinaryData.h
//  libnitrox
//
//  Created by Robert Sanders on 10/17/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NitroxBinaryData : NSObject {
    NSData*       data;
}

@property (retain) NSData*  data;

- (NitroxBinaryData*) initWithData:(NSData *)data;
- (NSString *)serializeToJSON;

@end
