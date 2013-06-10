//
//  FileManager.m
//  Wallpapers
//

#import "FileManager.h"

@implementation FileManager

// 指定したパスのディレクトリ一覧を取得
- (NSArray *)getDirectoryListWithString:(NSString *)aPath
{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:aPath error:nil];
}

// 指定したパスのディレクトリ一覧を取得
- (NSArray *)getDirectoryListWithURL:(NSURL *)aURL
{
    NSString *string = [[NSString alloc] initWithString:[aURL path]];

	return [self getDirectoryListWithString:string];
}

// 指定したパスのファイル一覧を取得
- (NSArray *)getFileListWithString:(NSString *)aPath;
{
	NSURL *url = [[NSURL alloc] initWithString:aPath];

	return [self getFileListWithURL:url];
}

// 指定したパスのファイル一覧を取得
- (NSArray *)getFileListWithURL:(NSURL *)aURL;
{
    NSURL *content;
    NSMutableArray *fileList = [[NSMutableArray alloc] initWithCapacity:0];

    NSDirectoryEnumerator *contents = [[NSFileManager defaultManager] enumeratorAtURL:aURL
														   includingPropertiesForKeys:nil
																			  options:NSDirectoryEnumerationSkipsHiddenFiles
																		 errorHandler:nil];
	while (content = [contents nextObject]) {
		if ([self isFile:content]) {
			[fileList addObject:content];
		}
	}

	return (NSArray *)fileList;
}

// 指定したパスがファイルであるかチェックする
- (BOOL)isFile:(NSURL *)aURL
{
    BOOL isDir;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:[aURL path] isDirectory:&isDir];

    if (isExist && !isDir) {
        return YES;
    }
    return NO;
}

// 指定したパスがディレクトリであるかチェックする
- (BOOL)isDirectory:(NSURL *)aURL
{
    BOOL isDir;
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:[aURL path] isDirectory:&isDir];

    if (isExist && isDir) {
        return YES;
    }
    return NO;
}

@end
