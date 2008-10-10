//
//  NitroxHTTPServerFilesystemDelegate.m
//  nitroxy1
//
//  Created by Robert Sanders on 10/3/08.
//  Copyright 2008 ViTrue, Inc.. All rights reserved.
//

#import "NitroxHTTPServerFilesystemDelegate.h"
#import "NitroxHTTPUtils.h"

@implementation NitroxHTTPServerFilesystemDelegate

@synthesize root, authoritative;

- (NitroxHTTPServerFilesystemDelegate *) initWithRoot:(NSString *)path authoritative:(BOOL)isauth 
{
    [super init];
    self.root = path;
    self.authoritative = isauth;
    
    return self;
}

- (NSString *) effectivePath:(NSString*)path {
    NSString *ePath = [NSString stringWithFormat:@"%@/%@",
            root, [NitroxHTTPUtils stripLeadingSlash:path]];

    BOOL exists;
    BOOL isDir;
    
    exists = [[NSFileManager defaultManager] fileExistsAtPath:ePath isDirectory:&isDir];
    if (exists && isDir) {
        ePath = [NSString stringWithFormat:@"%@/index.html", 
                 [NitroxHTTPUtils stripTrailingSlash:ePath]];
    }
    return ePath;
}

- (BOOL) willHandlePath:(NSString *)path
            fromRequest:(NitroxHTTPRequest *)request
               onServer:(NitroxHTTPServer *)server
{
    if (self.authoritative) {
        return YES;
    }
    
    NSString *ePath = [self effectivePath:path];
    
    return ([[NSFileManager defaultManager] fileExistsAtPath:ePath]);
}

- (NitroxHTTPResponseMessage *)httpServer:(NitroxHTTPServer *)server
                            handleRequest:(NitroxHTTPRequest *)request
                                   atPath:(NSString *)path
{
    NSString *ePath = [self effectivePath:request.path];
    
    NSLog(@"calculated file path is %@", ePath);
    
    NitroxHTTPResponseMessage* message;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager isReadableFileAtPath:ePath]) {
        NSData *contents = [NSData dataWithContentsOfFile:ePath];
        NSString *type = [NitroxHTTPUtils contentTypeForExtension:[ePath pathExtension]];
        if (!type) {
            type = @"application/octet-stream";
        }
        message = [NitroxHTTPResponseMessage responseWithBody:contents
                                                  contentType:type statusCode:200];
    } else if (authoritative) {
        message = [NitroxHTTPResponseMessage emptyResponseWithCode:404];
    } else {
        message = Nil;
    }
    
    return message;
}

- (void) dealloc {
    [root release];
    [super dealloc];
}

@end
