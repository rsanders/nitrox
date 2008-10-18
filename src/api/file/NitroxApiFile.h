//
//  NitroxApiFile.h
//
//

#import <UIKit/UIKit.h>

#import "NitroxRPC.h"

@interface NitroxApiFile : NitroxStubClass {
    NSFileManager   *fileManager;
}

- (NitroxApiFile *)init;


@end
