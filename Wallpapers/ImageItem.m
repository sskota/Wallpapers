//
//  ImageItem.m
//  Wallpapers
//

#import "ImageItem.h"

@implementation ImageItem

@synthesize imageURL;
@synthesize imageResolution;

+ (ImageItem *)imageItemWithContentsOfURL:(NSURL *)aURL
{
	return [[ImageItem alloc] initWithContentsOfURL:aURL];
}

- (id)initWithContentsOfURL:(NSURL *)aURL
{    
    self = [super init];
    if (self) {
        imageURL = [aURL copy];
        
        NSImage *image = [[NSImage alloc] initWithContentsOfURL:imageURL];
        NSBitmapImageRep* imageRep = [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
        NSSize imageSize = NSMakeSize([imageRep pixelsWide], [imageRep pixelsHigh]);
        
        NSString *width = [NSString stringWithFormat:@"%d",(int)imageSize.width];
        NSString *height = [NSString stringWithFormat:@"%d",(int)imageSize.height];
        
        imageResolution = [width stringByAppendingFormat:@"x%@", height];
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
	return self.imageURL;
}

- (NSString *)imageTitle
{
    return imageResolution;
    //return [[imageURL absoluteString] lastPathComponent];
}

- (NSString *)imageSubtitle
{
    //return imageResolution;
    return [[imageURL absoluteString] lastPathComponent];
}

@end
