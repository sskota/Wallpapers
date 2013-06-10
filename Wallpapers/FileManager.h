//
//  FileManager.h
//  Wallpapers
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

- (NSArray *)getDirectoryListWithString:(NSString *)aPath;
- (NSArray *)getDirectoryListWithURL:(NSURL *)aURL;
- (NSArray *)getFileListWithString:(NSString *)aPath;
- (NSArray *)getFileListWithURL:(NSURL *)aURL;
- (BOOL)isFile:(NSURL *)aPath;
- (BOOL)isDirectory:(NSURL *)aPath;

@end
