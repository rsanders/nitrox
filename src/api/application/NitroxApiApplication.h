//
//  NitroxApiApplication.h
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 Robert Sanders. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"

@interface NitroxApiApplication : NitroxStubClass {
    
}

- (NitroxApiApplication *)init;

// callable API functions

// single arg "url"
- (id) openApplication:(NSDictionary *)args;

// single arg "url"
- (id) openURL:(NSDictionary *)args;

// optional arg "hard" - true/false
- (id) exit:(NSDictionary *)args;

- (id) applicationIconBadgeNumber;

// single arg "value"
- (id) setApplicationIconBadgeNumber:(NSDictionary *)args;

- (id) bundleDirectory;
- (id) documentsDirectory;
- (id) tmpDirectory;
- (id) homeDirectory;
- (id) userDefaults;
- (id) infoDictionary;
- (id) appConfiguration;

// single arg "name"
- (id) getInfoValue:(NSDictionary *)args;

// single arg "name"
- (id) getUserDefault:(NSDictionary *)args;

// args "name" and "value"
- (id) setUserDefault:(NSDictionary *)args;

// single arg "names"
- (id) getUserDefaults:(NSDictionary *)args;

// single arg "defaults"
- (id) setUserDefaults:(NSDictionary *)args;

@end
