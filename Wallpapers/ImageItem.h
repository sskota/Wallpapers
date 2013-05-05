//
//  ImageItem.h
//  Wallpapers
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface ImageItem : NSObject

@property (retain) NSURL *imageURL;
@property (retain) NSString *imageName;

+ (ImageItem *)imageItemWithContentsOfURL:(NSURL *)aURL;
- (id)initWithContentsOfURL:(NSURL *)aURL;

@end

@interface ImageItem (IKImageBrowserItem)

- (NSString *)imageUID;
- (NSString *)imageRepresentationType;
- (id)imageRepresentation;
- (NSString *)imageTitle;
- (NSString *)imageSubtitle;

@end