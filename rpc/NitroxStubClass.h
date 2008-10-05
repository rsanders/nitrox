//
//  NitroxStubClass.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NitroxRPCDispatcher;

@interface NitroxStubClass : NSObject {
    NitroxRPCDispatcher*   dispatcher;
}

@property (retain,readonly)  NSString*    className;
@property (retain,readonly)  NSString*    classMethods;
@property (retain,readonly)  NSString*    instanceMethods;   
@property (assign) NitroxRPCDispatcher*   dispatcher;

- (id) newInstance;
- (id) newInstanceWithArgs:(NSDictionary *)args;

- (id) invokeClassMethod:(NSString *)method args:(NSDictionary *)args;

- (id) object:(id)object invoke:(NSString *)method args:(NSDictionary *)args;

@end
