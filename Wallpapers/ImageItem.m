//
//  ImageItem.m
//  Wallpapers
//

#import "ImageItem.h"

@interface ImageItem()

@property (retain) NSURL *imageURL;
@property (retain) NSString *imageName;

@end

@implementation ImageItem

@synthesize imageURL;
@synthesize imageName;

+ (ImageItem *)imageItemWithContentsOfURL:(NSURL *)aURL
{
	return [[ImageItem alloc] initWithContentsOfURL:aURL];
}

- (id)initWithContentsOfURL:(NSURL *)aURL
{    
    self = [super init];
    if (self) {

        imageURL = [aURL copy];

		// 画像からサイズを取得してタイトルにする
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
        NSSize imageSize = NSMakeSize([imageRep pixelsWide], [imageRep pixelsHigh]);
        NSString *width = [NSString stringWithFormat:@"%d",(int)imageSize.width];
        NSString *height = [NSString stringWithFormat:@"%d",(int)imageSize.height];
        
        imageName = [width stringByAppendingFormat:@"x%@", height];
    }
    return self;
}

@end

@implementation ImageItem (IKImageBrowserItem)

- (NSString *)imageUID
{
	return [imageURL absoluteString];
}

- (NSString *)imageRepresentationType
{
	return IKImageBrowserNSURLRepresentationType;
}

- (id)imageRepresentation
{
	return imageURL;
}

- (NSString *)imageTitle
{
    return imageName;
}

- (NSString *)imageSubtitle
{
    return [[imageURL absoluteString] lastPathComponent];
}

@end
