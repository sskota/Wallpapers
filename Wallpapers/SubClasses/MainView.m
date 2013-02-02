//
//  MainView.m
//  Wallpapers
//

#import "MainView.h"

@implementation MainView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    // 背景色の設定
    NSImage *backgroundImage = [NSImage imageNamed:@"background"];
    NSColor *backgroundColor = [NSColor colorWithPatternImage:backgroundImage];
    [backgroundColor set];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

@end
