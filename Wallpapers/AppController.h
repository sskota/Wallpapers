//
//  AppController.h
//  Wallpapers
//

#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
    IBOutlet IKImageBrowserView		*imageBrowser;
    IBOutlet NSPopUpButton			*categoryPopUpButton;
    IBOutlet NSPopUpButton			*screenPopUpButton;
    IBOutlet NSPopUpButton			*scalePopUpButton;
    IBOutlet NSColorWell			*fillColorWell;
    IBOutlet NSProgressIndicator	*loadingIndicator;
}

@property (retain) NSString			*mImageRootPath;
@property (retain) NSString			*mCategoryPath;
@property (retain) NSMutableArray	*mImages;
@property (retain) NSScreen			*mCurrentScreen;

- (IBAction)fillColorWellDidChange:(id)sender;
- (IBAction)zoomSliderDidChange:(id)sender;

@end
