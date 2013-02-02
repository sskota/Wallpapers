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
        
        //self.wantsLayer = YES;
        //self.layer.masksToBounds = YES;
        //self.layer.cornerRadius = 10.0;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    
    // 角丸フレームの設定
    //NSRect frame = self.bounds;
    //NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:frame xRadius:10.0 yRadius:10.0];
    //[path fill];
    //[path addClip];
    
    // 背景色の設定
    NSImage *backgroundImage = [NSImage imageNamed:@"background"];
    NSColor *backgroundColor = [NSColor colorWithPatternImage:backgroundImage];
    [backgroundColor set];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

@end
