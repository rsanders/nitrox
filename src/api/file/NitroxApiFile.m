//
//  NitroxApiFile.m
//
//

#import "NitroxApiFile.h"

#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>

@implementation NitroxApiFile

- (NitroxApiFile *)init
{
    [super init];

    fileManager = [[NSFileManager alloc] init];
    return self;
}

- (void) dealloc {
    [fileManager release];
    [super dealloc];
}

#pragma mark API specific methods
- (const char *) path2cString:(NSString *)string
{
    return [string cStringUsingEncoding:[NSString defaultCStringEncoding]];
}

// TODO
// accepts offset, size
- (id) read:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    
    NSData *res = Nil;

    NSString *soffset = [args objectForKey:@"offset"];
    NSString *ssize = [args objectForKey:@"size"];
    
    off_t offset = 0;
    if (soffset && ! [soffset isEqualToString:@""]) {
        offset = [soffset longLongValue];
    }

    off_t size = 0;
    if (ssize && ! [ssize isEqualToString:@""]) {
        size = [ssize longLongValue];
    }
    
    if (! [fileManager fileExistsAtPath:path]) {
        return Nil;
    }

    NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:path];
    if (!fh) {
        NSLog(@"got null fh for writing to path %@", path);
        return Nil;
    }

    if (offset > 0) {
        [fh seekToFileOffset:offset];
        if ([fh offsetInFile] != offset) {
            NSLog(@"premature end of file when seeking");
            [fh closeFile];
            return Nil;
        }
    }

    if (size > 0) {
        res = [fh readDataOfLength:size];
    } else {
        res = [fh readDataToEndOfFile];
    }
    
    [fh closeFile];
    
    return res;
}

// accepts: data, offset, mode
- (id) write:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    NSString *sdata = [args objectForKey:@"data"];
    if (!path || !sdata) {
        return Nil;
    }
    NSData *data = [sdata dataUsingEncoding:NSUTF8StringEncoding];
    NSString *smode = [args objectForKey:@"mode"];
    NSString *soffset = [args objectForKey:@"offset"];
    
    off_t offset = 0;
    if (soffset && ! [soffset isEqualToString:@""]) {
        offset = [soffset longLongValue];
    }

    if (! [fileManager fileExistsAtPath:path]) {
        BOOL res = [fileManager createFileAtPath:path 
                                        contents:data 
                                      attributes:Nil];
        if (!res) {
            NSLog(@"error creating file at path: %@", path);
        }
        return [self boolObject:res];
    }
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:path];
    if (!fh) {
        NSLog(@"got null fh for writing to path %@", path);
        return Nil;
    }
    if ((smode && [smode isEqualToString:@"w+"])
        || offset > 0)
    {
        if (offset <= 0) {
            [fh seekToEndOfFile];
        } else {
            [fh seekToFileOffset:offset];
        }
    }
    
    BOOL res = YES;
    @try {
        [fh writeData:data];
    } @catch (NSException *e) {
        res = NO;
        NSLog(@"failed to write to file %@: %@", path, e);
    }
    [fh closeFile];
    
    return [self boolObject:res];
}

- (id) unlink:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }

    int res = unlink([self path2cString:path]);
    return [self boolObject:(res == 0 ? YES : NO)];
}

// recursive
- (id) delete:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    
    NSError *error = Nil;
    if (! [fileManager removeItemAtPath:path error:&error]) {
        NSLog(@"could not delete item %@: %@", path, error);
        return [self boolObject:NO];
    } else {
        return [self boolObject:YES];
    }
}

- (id) access:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    
    NSString *smode = [args objectForKey:@"mode"];
    if (!smode) {
        return Nil;
    }

    int amode = 0;
    smode = [smode lowercaseString];
    for (int i = 0; i < [smode length]; i++) {
        unichar c = [smode characterAtIndex:i];
        switch (c) {
            case 'w':
                amode |= W_OK;
                break;
            case 'r':
                amode |= R_OK;
                break;
            case 'x':
                amode |= X_OK;
                break;
            case 'f':
                amode |= F_OK;
                break;
        }
    }
    
    int res = access([self path2cString:path], amode);
    return [self boolObject:(res == 0 ? YES : NO)];
}

- (NSNumber *)time2number:(struct timespec)spec
{
    double dbltime;
    
    dbltime = spec.tv_sec;
    dbltime += (spec.tv_nsec) / 1000000000.0;
    
    return [NSNumber numberWithDouble:dbltime];
}

- (id) stat:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    
    struct stat buf;
    int res = stat([self path2cString:path], &buf);
    if (res == -1) {
        return Nil;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInteger:buf.st_dev], @"st_dev",
                          [NSNumber numberWithInteger:buf.st_ino], @"st_ino",
                          [NSNumber numberWithInteger:buf.st_mode], @"st_mode",
                          [NSNumber numberWithInteger:buf.st_nlink], @"st_nlink",
                          [NSNumber numberWithInteger:buf.st_uid], @"st_uid",
                          [NSNumber numberWithInteger:buf.st_gid], @"st_gid",
                          [NSNumber numberWithInteger:buf.st_rdev], @"st_rdev",
                          
                          [self time2number:buf.st_atimespec], @"st_atime",
                          [self time2number:buf.st_mtimespec], @"st_mtime",
                          [self time2number:buf.st_ctimespec], @"st_ctime",
                          [self time2number:buf.st_birthtimespec], @"st_birthtime",
                          
                          [NSNumber numberWithInteger:buf.st_size], @"st_size",
                          [NSNumber numberWithInteger:buf.st_blocks], @"st_blocks",
                          [NSNumber numberWithInteger:buf.st_blksize], @"st_blksize",
                          [NSNumber numberWithInteger:buf.st_flags], @"st_flags",
                          [NSNumber numberWithInteger:buf.st_gen], @"st_gen",
                          Nil];
    return dict;
}

- (id) chmod:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }

    NSString *smode = [args objectForKey:@"mode"];
    int mode = [smode intValue];
    
    int res = chmod([self path2cString:path], mode);
    return [self boolObject:(res == 0 ? YES : NO)];
}

- (id) truncate:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }

    NSString *ssize = [args objectForKey:@"size"];
    size_t size = [ssize integerValue];
    
    int res = truncate([self path2cString:path], size);
    return [self boolObject:(res == 0 ? YES : NO)];
}

- (id) link:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }

    NSString *path2 = [args objectForKey:@"path2"];
    if (!path2) {
        return Nil;
    }
    int res = link([self path2cString:path], [self path2cString:path2]);
    return [self boolObject:(res == 0 ? YES : NO)];
}

- (id) copy:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    
    NSString *path2 = [args objectForKey:@"path2"];
    if (!path2) {
        return Nil;
    }

    NSError *error = Nil;
    BOOL res = [fileManager copyItemAtPath:path toPath:path2 error:&error];
    if (! res) {
        NSLog(@"failed to copy from %@ to %@: %@", path, path2, error);
    }
    
    return [self boolObject:res];
}

- (id) symlink:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }

    NSString *path2 = [args objectForKey:@"path2"];
    if (!path2) {
        return Nil;
    }

    int res = symlink([self path2cString:path], [self path2cString:path2]);
    return [self boolObject:(res == 0 ? YES : NO)];    
}


- (id) mkdir:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    int mode = 0755;
    NSString *smode = [args objectForKey:@"mode"];
    if (smode) {
        mode = [smode intValue];
    }
    
    BOOL recursive = YES;
    NSString *srecursive = [args objectForKey:@"recursive"];
    if (srecursive && ! [srecursive isEqualToString:@""]) {
        recursive = [srecursive boolValue];
    }
    
    NSDictionary *attr = [NSDictionary dictionaryWithObject:[NSNumber numberWithLong:mode]
                                                     forKey:NSFilePosixPermissions];
    
    NSError *error = Nil;
    BOOL res = [fileManager createDirectoryAtPath:path
                      withIntermediateDirectories:recursive 
                                       attributes:attr
                                            error:&error];
    if (! res) {
        NSLog(@"failed to create directory %@: %@", path, error);
    }
    return [self boolObject:res];
}

//- (id) mkdir:(NSDictionary *)args
//{
//    NSString *path = [args objectForKey:@"path"];
//    if (!path) {
//        return Nil;
//    }
//    int mode = 0755;
//    NSString *smode = [args objectForKey:@"mode"];
//    if (smode) {
//        mode = [smode intValue];
//    }
//    
//    int res = mkdir([self path2cString:path], mode);
//    return [self boolObject:(res == 0 ? YES : NO)];
//}

- (id) rmdir:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    int res = rmdir([self path2cString:path]);
    return [self boolObject:(res == 0 ? YES : NO)];
}

- (id) readdir:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    
    return [fileManager directoryContentsAtPath:path];
}


# pragma mark non-filehandle methods (class methods)

- (id) chdir:(NSDictionary *)args
{
    NSString *path = [args objectForKey:@"path"];
    if (!path) {
        return Nil;
    }
    return [self boolObject:[fileManager changeCurrentDirectoryPath:path]];
}

- (id) getcwd
{
    return [fileManager currentDirectoryPath];
}




#pragma mark delegate and notification methods

#pragma mark support methods


@end
