//
//  AppController.m
//  Wallpapers
//

#import "AppController.h"
#import "ImageItem.h"
#import "FileManager.h"

#define NON_CATEGORY @"---"

@implementation AppController

@synthesize imageRootPath;
@synthesize categoryPath;
@synthesize images;
@synthesize currentScreen;

enum SCALE_OPTION {
    SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP = 0,
    SCALE_PROPORTIONALLY_UP_OR_DOWN_NOCLIP = 1,
    SCALE_AXIS_INDEPENDENTRY = 2,
    SCALE_NONE = 3,
};

enum CLIPPING_OPTION {
    CLIPPING_ON = 1,
    CLIPPING_OFF = 0,
};

- (void)awakeFromNib
{
    images = [[NSMutableArray alloc] init];
    
    // イメージブラウザの背景を透明にする
    [imageBrowser setValue:[NSColor clearColor] forKey:IKImageBrowserBackgroundColorKey];
    
    // スクリーン設定のメニュー作成
    [self updateScreenOptionList];
    
    // スケール設定のメニュー作成
    [self updateScaleOptionList];
    
    // 画面設定の更新
    [self updateScreenOptions:currentScreen];
    
    // 言語設定
    [self languageSetting];
    
    // 画像フォルダの設定
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *resourcePath = [bundle bundlePath];
    imageRootPath = [NSString stringWithString:[resourcePath stringByAppendingPathComponent:@"Contents/Resources/Images.bundle"]];
    
    // 画像フォルダのリスト取得
    FileManager *fileManager = [[FileManager alloc] init];
    NSArray *list = [[NSArray alloc] initWithArray:[fileManager getImageDirectoryList:imageRootPath]];
    
    // カテゴリリストのメニュー作成
    [self updateCategoryList:list];
}

// 現在の設定を取得しオプションに反映する
- (void)updateScreenOptions:(NSScreen *)aScreen
{
	if (aScreen != nil) {
        
		NSDictionary *screenOptions = [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:currentScreen];
		NSNumber *scalingFactor = [screenOptions objectForKey:NSWorkspaceDesktopImageScalingKey];
        NSNumber *allowClipping = [screenOptions objectForKey:NSWorkspaceDesktopImageAllowClippingKey];
            
        NSInteger scaleValue;
        switch ([scalingFactor intValue]) {
            case NSImageScaleProportionallyUpOrDown:
                    
                if ([allowClipping boolValue]) {
                    scaleValue = SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP;
                } else {
                    scaleValue = SCALE_PROPORTIONALLY_UP_OR_DOWN_NOCLIP;
                }
                break;
                
            case NSImageScaleAxesIndependently:
                
                scaleValue = SCALE_AXIS_INDEPENDENTRY;
                break;
                
            case NSImageScaleNone:
                
                scaleValue = SCALE_NONE;
                break;
                
            default:
                
                scaleValue = SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP;
                break;
        }
        [scalePopUpButton selectItemAtIndex:scaleValue];
        
		NSColor *fillColorValue = [screenOptions objectForKey:NSWorkspaceDesktopImageFillColorKey];
		if (fillColorValue) {
			[fillColorWell setColor:fillColorValue];
        }
	}
}

// スクリーンリストを生成して更新する
- (void)updateScreenOptionList
{
    NSMenu *screensMenu = [[NSMenu alloc] initWithTitle:@"Screens"];
	NSArray *screens = [NSScreen screens];
    NSScreen *iterScreen = [[NSScreen alloc] init];
	NSUInteger screenIndex = 1;
    
    for (iterScreen in screens) {
        
		NSString *screenTitle;
		if (iterScreen == [NSScreen mainScreen]) {
			screenTitle = NSLocalizedString(@"MAIN_SCREEN", "");
		} else {
			screenTitle = [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"SCREEN", ""), (long)screenIndex];
		}
        
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:screenTitle action:@selector(selectScreenOption:) keyEquivalent:@""];
		[item setRepresentedObject:iterScreen];
        [item setTarget:self];
		[screensMenu addItem:item];
        
		if (iterScreen == [NSScreen mainScreen]) {
			[screenPopUpButton selectItem:item];
			currentScreen = iterScreen;
		}
		screenIndex++;
	}
	
	[screenPopUpButton setMenu:screensMenu];
}

// スケールオプションリストを生成して更新する
- (void)updateScaleOptionList
{
    NSMenu *scaleMenu = [[NSMenu alloc] init];
    
    NSMenuItem *itemFillScreen =
    [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OPTION_PROPORTIONALLY_UP_OR_DOWN_CLIP", "")
                               action:@selector(selectScaleOption:)
                        keyEquivalent:@""];
    
    NSMenuItem *itemFitToScreen =
    [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OPTION_PROPORTIONALLY_UP_OR_DOWN_NOCLIP", "")
                               action:@selector(selectScaleOption:)
                        keyEquivalent:@""];

    NSMenuItem *itemStretchToFillScreen =
    [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OPTION_AXIS_INDEPENDENTRY", "")
                               action:@selector(selectScaleOption:)
                        keyEquivalent:@""];
    
    NSMenuItem *itemCenter =
    [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"OPTION_NONE", "")
                               action:@selector(selectScaleOption:)
                        keyEquivalent:@""];
    
    [itemFillScreen setTarget:self];
    [itemFitToScreen setTarget:self];
    [itemStretchToFillScreen setTarget:self];
    [itemCenter setTarget:self];

    [scaleMenu addItem:itemFillScreen];
    [scaleMenu addItem:itemFitToScreen];
    [scaleMenu addItem:itemStretchToFillScreen];
    [scaleMenu addItem:itemCenter];
    
    [scalePopUpButton setMenu:scaleMenu];
}

// カテゴリーリストを生成して更新する
- (void)updateCategoryList:(NSArray *)aList
{
    NSMenu *catMenu = [[NSMenu alloc] init];
    
    NSMenuItem *nonCat = [[NSMenuItem alloc] initWithTitle:NON_CATEGORY action:@selector(selectCategory:) keyEquivalent:@""];
    [nonCat setTarget:self];
    [catMenu addItem:nonCat];
    
    NSInteger index = 0;
    for (NSString *menuName in aList) {
        NSMenuItem *menu = [[NSMenuItem alloc] initWithTitle:menuName action:@selector(selectCategory:) keyEquivalent:@""];
        [menu setTarget:self];
        [catMenu addItem:menu];
        index++;
    }
    
    [categoryPopUpButton setMenu:catMenu];
    
    [self selectCategory:nil];
}

// URLパスから画像を追加する
- (void)addImagesFromDirectory:(NSURL *)aURL
{
    [self lockObject:YES];
    
    [loadingIndicator startAnimation:self];
    [loadingIndicator setHidden:NO];
    
    [images removeAllObjects];
    
    FileManager *manager = [[FileManager alloc] init];
    NSArray *content = [manager getImageFileList:aURL];
    
    for (NSURL *imageURL in content) {
        [self addImage:imageURL];
    }
    
    [loadingIndicator setHidden:YES];
    [loadingIndicator stopAnimation:self];
    
    [self performSelectorOnMainThread:@selector(addImagesFromDirectoryDidFinish) withObject:nil waitUntilDone:NO];
}

// 画像追加が完了した際のイベント
- (void)addImagesFromDirectoryDidFinish
{
    [imageBrowser reloadData];
    [self lockObject:NO];
}

// ブラウザに画像を追加
- (void)addImage:(NSURL *)aURL
{
	ImageItem *item = [ImageItem imageItemWithContentsOfURL:aURL];
	[images addObject:item];
}

// コントロールのロックを切り替える
- (void)lockObject:(BOOL)enable
{
    [categoryPopUpButton setEnabled:!enable];
    [screenPopUpButton setEnabled:!enable];
    [scalePopUpButton setEnabled:!enable];
    [fillColorWell setEnabled:!enable];
}

#pragma mark - Popup Selector

// カテゴリーを更新した際のアクション
- (void)selectCategory:(id)sender
{
    NSString *menuString = [categoryPopUpButton titleOfSelectedItem];
    
    if ([[categoryPopUpButton titleOfSelectedItem] isEqualToString:NON_CATEGORY]) {
        categoryPath = imageRootPath;
    } else {
        categoryPath = [NSString stringWithString:[imageRootPath stringByAppendingPathComponent:menuString]];
    }
    
    NSURL *directoryURL = [NSURL fileURLWithPath:categoryPath];
    
    // 別スレッドで実行
    [self performSelectorInBackground:@selector(addImagesFromDirectory:) withObject:directoryURL];
}

// スクリーンオプションを更新した際のアクション
- (void)selectScreenOption:(id)sender
{
	NSMenuItem *chosenItem = (NSMenuItem *)sender;
	NSScreen *screen = [chosenItem representedObject];
	currentScreen = screen;
    
	[self updateScreenOptions:screen];
}

// スケール設定を更新した際のアクション
- (void)selectScaleOption:(id)sender
{
	// 現在の画面設定を取得
    NSMutableDictionary *screenOptions = [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:currentScreen] mutableCopy];
	
    // スケール設定を取得
    NSInteger scalingFactor = [scalePopUpButton indexOfSelectedItem];
    
    NSInteger scaleValue;
    NSInteger clipValue;
    
    switch (scalingFactor) {
        case SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP:
            
            scaleValue = NSImageScaleProportionallyUpOrDown;
            clipValue = CLIPPING_ON;
            break;
            
        case SCALE_PROPORTIONALLY_UP_OR_DOWN_NOCLIP:
            
            scaleValue = NSImageScaleProportionallyUpOrDown;
            clipValue = CLIPPING_OFF;
            break;
            
        case SCALE_AXIS_INDEPENDENTRY:
            
            scaleValue = NSImageScaleAxesIndependently;
            clipValue = CLIPPING_OFF;
            break;
            
        case SCALE_NONE:
            
            scaleValue = NSImageScaleNone;
            clipValue = CLIPPING_OFF;
            break;
            
        default:
            
            scaleValue = NSImageScaleProportionallyUpOrDown;
            clipValue = CLIPPING_ON;
            break;
    }
    
    // スケール設定を適用する
	[screenOptions setObject:[NSNumber numberWithInteger:scaleValue] forKey:NSWorkspaceDesktopImageScalingKey];
    
    // クリッピング設定を適用する
	[screenOptions setObject:[NSNumber numberWithInteger:clipValue] forKey:NSWorkspaceDesktopImageAllowClippingKey];
	
    // ワークスペースに反映
	NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:currentScreen];
	[[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL forScreen:currentScreen options:screenOptions error:nil];
}

#pragma mark - Actions

// 背景色を変更した際のアクション
- (IBAction)fillColorWellDidChange:(id)sender
{
	// 現在の画面設定を取得
	NSMutableDictionary *screenOptions = [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:currentScreen] mutableCopy];
    
	// 背景色パネルの設定を取得
	NSColor *fillColorValue = [fillColorWell color];
    
	// 背景色設定を適用する
	[screenOptions setObject:fillColorValue forKey:NSWorkspaceDesktopImageFillColorKey];
	
    // ワークスペースに反映
	NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:currentScreen];
	[[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL forScreen:currentScreen options:screenOptions error:nil];
}

// ズームスライダーを更新した際のアクション
- (IBAction)zoomSliderDidChange:(id)sender
{
	[imageBrowser setZoomValue:[sender floatValue]];
}

#pragma mark - IKImageBrowserDataSource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
	return [images count];
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index
{
	return [images objectAtIndex:index];
}

#pragma mark - IKImageBrowserDelegate

// 画像をクリックした際のアクション
- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser
{
	NSIndexSet *selectionIndexes = [aBrowser selectionIndexes];
	
	if ([selectionIndexes count] > 0) {
        
        NSDictionary *screenOptions = [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:currentScreen];
        ImageItem *item = [images objectAtIndex:[selectionIndexes firstIndex]];
		NSURL *url = [item imageRepresentation];
        
        NSNumber *isDirectoryFlag = nil;
        if ([url getResourceValue:&isDirectoryFlag forKey:NSURLIsDirectoryKey error:nil] && ![isDirectoryFlag boolValue]) {
            
            NSError *error = nil;
            [[NSWorkspace sharedWorkspace] setDesktopImageURL:url forScreen:currentScreen options:screenOptions error:&error];
            if (error) {
                [NSApp presentError:error];
            }
        }
	}
}

#pragma mark - Language Setting

- (void)languageSetting
{
    [exitButton setTitle:NSLocalizedString(@"BUTTON_EXIT", "")];
    [screenTextField setStringValue:NSLocalizedString(@"TEXTVIEW_SCREEN", "")];
    [optionTextField setStringValue:NSLocalizedString(@"TEXTVIEW_OPTION", "")];
    [categoryTextField setStringValue:NSLocalizedString(@"TEXTVIEW_CATEGORY", "")];
    [zoomTextField setStringValue:NSLocalizedString(@"TEXTVIEW_ZOOM", "")];
}

@end
