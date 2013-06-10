//
//  AppController.h
//  Wallpapers
//

#import <Quartz/Quartz.h>
#import <Cocoa/Cocoa.h>

#define NON_CATEGORY @"---"
#define IMAGES_BUNDLE @"Contents/Resources/Images.bundle"

enum SCALE_OPTION
{
    SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP = 0,
    SCALE_PROPORTIONALLY_UP_OR_DOWN_NOCLIP = 1,
    SCALE_AXIS_INDEPENDENTRY = 2,
    SCALE_NONE = 3,
};

enum CLIPPING_OPTION
{
    CLIPPING_ON = 1,
    CLIPPING_OFF = 0,
};

@interface AppController : NSObject {
    IBOutlet IKImageBrowserView *imageBrowser;
    IBOutlet NSPopUpButton *categoryPopUpButton;
    IBOutlet NSPopUpButton *screenPopUpButton;
    IBOutlet NSPopUpButton *scalePopUpButton;
    IBOutlet NSColorWell *fillColorWell;
    IBOutlet NSProgressIndicator *loadingIndicator;
}

- (IBAction)fillColorWellDidChange:(id)sender;
- (IBAction)zoomSliderDidChange:(id)sender;

@end
