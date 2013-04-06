//
//  ImageItem.m
//  Wallpapers
//

#import "ImageItem.h"

@implementation ImageItem

@synthesize mImageURL;
@synthesize mImageTitle;

+ (ImageItem *)imageItemWithContentsOfURL:(NSURL *)aURL
{
	return [[ImageItem alloc] initWithContentsOfURL:aURL];
}

- (id)initWithContentsOfURL:(NSURL *)aURL
{    
    self = [super init];
    if (self) {

        mImageURL = [aURL copy];

		// 画像からサイズを取得してタイトルにする
        NSImage				*image		= [[NSImage alloc] initWithContentsOfURL:mImageURL];
        NSBitmapImageRep	*imageRep	= [NSBitmapImageRep imageRepWithData:[image TIFFRepresentation]];
        NSSize				imageSize	= NSMakeSize([imageRep pixelsWide], [imageRep pixelsHigh]);
        NSString			*width		= [NSString stringWithFormat:@"%d",(int)imageSize.width];
        NSString			*height		= [NSString stringWithFormat:@"%d",(int)imageSize.height];
        
        mImageTitle = [width stringByAppendingFormat:@"x%@", height];
    }
    return self;
}

@end

@implementation ImageItem (IKImageBrowserItem)

- (NSString *)imageUID
{
	return [mImageURL absoluteString];
}

- (NSString *)imageRepresentationType
{
	return IKImageBrowserNSURLRepresentationType;
}

- (id)imageRepresentation
{
	return mImageURL;
}

- (NSString *)imageTitle
{
    return mImageTitle;
    //return [[imageURL absoluteString] lastPathComponent];
}

- (NSString *)imageSubtitle
{
    //return imageResolution;
    return [[mImageURL absoluteString] lastPathComponent];
}

@end
