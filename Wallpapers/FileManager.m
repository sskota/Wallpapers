//
//  FileManager.m
//  Wallpapers
//

#import "FileManager.h"

@implementation FileManager

- (NSArray *)getImageDirectoryList:(NSString *)aPath
{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aPath error:nil];
}

- (NSArray *)getImageFileList:(NSURL *)aURL;
{
    NSURL *content;
    NSMutableArray *fileList = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSDirectoryEnumerator *contents =
    [[NSFileManager defaultManager] enumeratorAtURL:aURL
                         includingPropertiesForKeys:nil
                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                       errorHandler:nil];
    
    while(content = [contents nextObject]) {
        if ([self isFile:content]) {
            [fileList addObject:content];
        }
    }
    
    return (NSArray *)fileList;
}

- (BOOL)isFile:(NSURL *)aPath
{
    BOOL isDir;
    BOOL isExit = [[NSFileManager defaultManager] fileExistsAtPath:[aPath path] isDirectory:&isDir];
    
    if (isExit && !isDir) {
        return YES;
    }
    return NO;
}

@end
