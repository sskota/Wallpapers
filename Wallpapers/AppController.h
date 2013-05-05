//
//  AppController.h
//  Wallpapers
//

#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>

@interface AppController : NSObject
{
    IBOutlet IKImageBrowserView *imageBrowser;
    IBOutlet NSPopUpButton *categoryPopUpButton;
    IBOutlet NSPopUpButton *screenPopUpButton;
    IBOutlet NSPopUpButton *scalePopUpButton;
    IBOutlet NSColorWell *fillColorWell;
    IBOutlet NSProgressIndicator *loadingIndicator;
}

@property (retain) NSString *imageRootPath;
@property (retain) NSString *categoryPath;
@property (retain) NSMutableArray *images;
@property (retain) NSScreen *currentScreen;

- (IBAction)fillColorWellDidChange:(id)sender;
- (IBAction)zoomSliderDidChange:(id)sender;

@end
