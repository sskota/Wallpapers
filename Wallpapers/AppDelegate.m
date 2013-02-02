//
//  AppDelegate.m
//  Wallpapers
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [window setBackgroundColor:[NSColor clearColor]];
    [window setOpaque:NO];
    [window setMovableByWindowBackground:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
