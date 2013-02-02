//
//  FileManager.h
//  Wallpapers
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject

- (NSArray *)getImageDirectoryList:(NSString *)aPath;
- (NSArray *)getImageFileList:(NSURL *)aURL;
- (BOOL)isFile:(NSURL *)aPath;

@end
