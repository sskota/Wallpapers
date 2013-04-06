//
//  AppController.m
//  Wallpapers
//

#import "AppController.h"
#import "ImageItem.h"
#import "FileManager.h"

#define NON_CATEGORY	@"---"
#define IMAGES_BUNDLE	@"Contents/Resources/Images.bundle"

@implementation AppController

@synthesize mImageRootPath;
@synthesize mCategoryPath;
@synthesize mImages;
@synthesize mCurrentScreen;

enum SCALE_OPTION
{
    SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP	= 0,
    SCALE_PROPORTIONALLY_UP_OR_DOWN_NOCLIP	= 1,
    SCALE_AXIS_INDEPENDENTRY				= 2,
    SCALE_NONE								= 3,
};

enum CLIPPING_OPTION
{
    CLIPPING_ON		= 1,
    CLIPPING_OFF	= 0,
};

/**
 * 初期設定
 */
- (void)awakeFromNib
{
	// ブラウザの背景色設定
	NSColor *color = [NSColor colorWithCalibratedWhite:0.15 alpha:1.0];
	[imageBrowser setValue:color forKey:IKImageBrowserBackgroundColorKey];

	// バンドルパスから初期ディレクトリの設定
    NSBundle	*bundle			= [NSBundle mainBundle];
    NSString	*bundlePath		= [bundle bundlePath];
	mImageRootPath = [NSString stringWithString:[bundlePath stringByAppendingPathComponent:IMAGES_BUNDLE]];

	// データソースの初期化
	mImages = [[NSMutableArray alloc] init];

	// 初期フォルダ内のリストを取得
    FileManager	*fileManager	= [[FileManager alloc] init];
    NSArray		*directoryList	= [[NSArray alloc] initWithArray:[fileManager getImageDirectoryList:mImageRootPath]];

	[self updateScreenList];
    [self updateScaleList];
    [self updateScreenOptions:mCurrentScreen];
	[self updateCategoryList:directoryList];
}

/**
 * 画面設定を取得しオプションに反映する
 */
- (void)updateScreenOptions:(NSScreen *)aScreen
{
	if (aScreen != nil) {
        
		NSDictionary	*screenOptions	= [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:mCurrentScreen];
		NSNumber		*scalingFactor	= [screenOptions objectForKey:NSWorkspaceDesktopImageScalingKey];
        NSNumber		*allowClipping	= [screenOptions objectForKey:NSWorkspaceDesktopImageAllowClippingKey];
        NSInteger		scaleValue;

		switch ([scalingFactor intValue]) {
		case NSImageScaleProportionallyUpOrDown:
                    
			if ([allowClipping boolValue]) {
				scaleValue = SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP;
			}
			else {
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
        
		NSColor	*fillColorValue	= [screenOptions objectForKey:NSWorkspaceDesktopImageFillColorKey];
		if (fillColorValue) {
			[fillColorWell setColor:fillColorValue];
        }
	}
}

/**
 * 画面リストの更新
 */
- (void)updateScreenList
{
    NSMenu		*screensMenu	= [[NSMenu alloc] initWithTitle:@"Screens"];
	NSArray		*screens		= [NSScreen screens];
    NSScreen	*screen			= [[NSScreen alloc] init];
	NSInteger	screenIndex		= 1;

	// 画面数分処理を繰り返してリストを生成
    for (screen in screens) {
        
		NSString *screenTitle;

		if (screen == [NSScreen mainScreen]) {
			screenTitle = NSLocalizedString(@"MAIN_SCREEN", "");
		}
		else {
			screenTitle = [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"SCREEN", ""), (long)screenIndex];
		}

		// メニューに追加する
		NSMenuItem *itemTitle = [[NSMenuItem alloc] initWithTitle:screenTitle action:@selector(selectScreenOption:) keyEquivalent:@""];
		[itemTitle setRepresentedObject:screen];
        [itemTitle setTarget:self];
		[screensMenu addItem:itemTitle];

		// メイン画面の場合は選択しておく
		if (screen == [NSScreen mainScreen]) {
			[screenPopUpButton selectItem:itemTitle];
			mCurrentScreen = screen;
		}
		screenIndex++;
	}
	
	[screenPopUpButton setMenu:screensMenu];
}

/**
 * スケールリストの更新
 */
- (void)updateScaleList
{
	// スケール設定は個別にメニューを用意

	NSMenu *scaleMenu = [[NSMenu alloc] init];

    NSMenuItem *itemFill	= [[NSMenuItem alloc]
							   initWithTitle:NSLocalizedString(@"OPTION_PROPORTIONALLY_UP_OR_DOWN_CLIP", "")
							   action:@selector(selectScaleOption:)
							   keyEquivalent:@""];
    
    NSMenuItem *itemFit		= [[NSMenuItem alloc]
							   initWithTitle:NSLocalizedString(@"OPTION_PROPORTIONALLY_UP_OR_DOWN_NOCLIP", "")
							   action:@selector(selectScaleOption:)
							   keyEquivalent:@""];

    NSMenuItem *itemStretch	= [[NSMenuItem alloc]
							   initWithTitle:NSLocalizedString(@"OPTION_AXIS_INDEPENDENTRY", "")
							   action:@selector(selectScaleOption:)
							   keyEquivalent:@""];
    
    NSMenuItem *itemCenter	= [[NSMenuItem alloc]
							   initWithTitle:NSLocalizedString(@"OPTION_NONE", "")
							   action:@selector(selectScaleOption:)
							   keyEquivalent:@""];
    
    [itemFill		setTarget:self];
    [itemFit		setTarget:self];
    [itemStretch	setTarget:self];
    [itemCenter		setTarget:self];

    [scaleMenu addItem:itemFill];
    [scaleMenu addItem:itemFit];
    [scaleMenu addItem:itemStretch];
    [scaleMenu addItem:itemCenter];
    
    [scalePopUpButton setMenu:scaleMenu];
}

/**
 * カテゴリリストの更新
 */
- (void)updateCategoryList:(NSArray *)aList
{
    NSMenu		*categoryMenu = [[NSMenu alloc] init];

	// カテゴリなしを設定
    NSMenuItem	*defaultItem = [[NSMenuItem alloc] initWithTitle:NON_CATEGORY action:@selector(selectCategory:) keyEquivalent:@""];
    [defaultItem setTarget:self];
    [categoryMenu addItem:defaultItem];

	// リストの内容を全て追加する
    NSInteger index = 0;
    for (NSString *menuName in aList) {
		
        NSMenuItem *menu = [[NSMenuItem alloc] initWithTitle:menuName action:@selector(selectCategory:) keyEquivalent:@""];
        [menu setTarget:self];
        [categoryMenu addItem:menu];
		
        index++;
    }
    
    [categoryPopUpButton setMenu:categoryMenu];
    
    [self selectCategory:nil];
}

/**
 * 画像追加処理の開始
 */
- (void)addImagesFromDirectory:(NSURL *)aURL
{
    [self lockObject:YES];
    
    [loadingIndicator startAnimation:self];
    [loadingIndicator setHidden:NO];
    
    [mImages removeAllObjects];
    
    FileManager	*manager	= [[FileManager alloc] init];
    NSArray		*content	= [manager getImageFileList:aURL];
    
    for (NSURL *imageURL in content) {
        [self addImage:imageURL];
    }
    
    [loadingIndicator setHidden:YES];
    [loadingIndicator stopAnimation:self];
    
    [self performSelectorOnMainThread:@selector(addImagesFromDirectoryDidFinish) withObject:nil waitUntilDone:NO];
}

/**
 * 画像追加処理の終了
 */
- (void)addImagesFromDirectoryDidFinish
{
    [imageBrowser reloadData];
    [self lockObject:NO];
}

/**
 * ブラウザに画像追加
 */
- (void)addImage:(NSURL *)aURL
{
	ImageItem *item = [ImageItem imageItemWithContentsOfURL:aURL];
	[mImages addObject:item];
}

/**
 * ロック切替
 */
- (void)lockObject:(BOOL)enable
{
    [categoryPopUpButton setEnabled:!enable];
    [screenPopUpButton setEnabled:!enable];
    [scalePopUpButton setEnabled:!enable];
    [fillColorWell setEnabled:!enable];
}

#pragma mark - Popup Selector

/**
 * カテゴリリストが選択された際の処理
 */
- (void)selectCategory:(id)sender
{
    NSString *menuString = [categoryPopUpButton titleOfSelectedItem];

	// カテゴリなしの場合は初期ディレクトリを設定
    if ([[categoryPopUpButton titleOfSelectedItem] isEqualToString:NON_CATEGORY]) {
        mCategoryPath = mImageRootPath;
    }
	else {
        mCategoryPath = [NSString stringWithString:[mImageRootPath stringByAppendingPathComponent:menuString]];
    }
    
    NSURL *directoryURL = [NSURL fileURLWithPath:mCategoryPath];
    
    // バックグラウンドで画像の追加処理を開始する
    [self performSelectorInBackground:@selector(addImagesFromDirectory:) withObject:directoryURL];
}

/**
 * 画面リストが選択された際の処理
 */
- (void)selectScreenOption:(id)sender
{
	NSMenuItem	*chosenItem	= (NSMenuItem *)sender;
	NSScreen	*screen		= [chosenItem representedObject];

	// 選択された画面アイテムを現在の画面に設定
	mCurrentScreen = screen;
    
	[self updateScreenOptions:screen];
}

/**
 * スケールリストが選択された際の処理
 */
- (void)selectScaleOption:(id)sender
{
    NSMutableDictionary		*screenOptions	= [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:mCurrentScreen] mutableCopy];
    NSInteger				scalingFactor	= [scalePopUpButton indexOfSelectedItem];
    NSInteger				scaleValue;
    NSInteger				clipValue;
    
    switch (scalingFactor) {
	case SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP:
            
		scaleValue	= NSImageScaleProportionallyUpOrDown;
		clipValue	= CLIPPING_ON;
		break;
            
	case SCALE_PROPORTIONALLY_UP_OR_DOWN_NOCLIP:
            
		scaleValue	= NSImageScaleProportionallyUpOrDown;
		clipValue	= CLIPPING_OFF;
		break;
            
	case SCALE_AXIS_INDEPENDENTRY:
            
		scaleValue	= NSImageScaleAxesIndependently;
		clipValue	= CLIPPING_OFF;
		break;
            
	case SCALE_NONE:

		scaleValue	= NSImageScaleNone;
		clipValue	= CLIPPING_OFF;
		break;
            
	default:
            
		scaleValue	= NSImageScaleProportionallyUpOrDown;
		clipValue	= CLIPPING_ON;
		break;
    }
    
    // スケール設定を適用する
	[screenOptions setObject:[NSNumber numberWithInteger:scaleValue] forKey:NSWorkspaceDesktopImageScalingKey];
    
    // クリッピング設定を適用する
	[screenOptions setObject:[NSNumber numberWithInteger:clipValue] forKey:NSWorkspaceDesktopImageAllowClippingKey];
	
    // ワークスペースに反映
	NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:mCurrentScreen];
	[[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL forScreen:mCurrentScreen options:screenOptions error:nil];
}

#pragma mark - Action

/**
 * 背景色設定が更新された際の処理
 */
- (IBAction)fillColorWellDidChange:(id)sender
{
	NSMutableDictionary		*screenOptions	= [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:mCurrentScreen] mutableCopy];
	NSColor					*fillColorValue	= [fillColorWell color];
    
	// 背景色設定を適用する
	[screenOptions setObject:fillColorValue forKey:NSWorkspaceDesktopImageFillColorKey];
	
    // ワークスペースに反映
	NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:mCurrentScreen];
	[[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL forScreen:mCurrentScreen options:screenOptions error:nil];
}

/**
 * ズームスライダーが更新された際の処理
 */
- (IBAction)zoomSliderDidChange:(id)sender
{
	[imageBrowser setZoomValue:[sender floatValue]];
}

#pragma mark - IKImageBrowserDataSource

- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)view
{
	return [mImages count];
}

- (id)imageBrowser:(IKImageBrowserView *)view itemAtIndex:(NSUInteger)index
{
	return [mImages objectAtIndex:index];
}

#pragma mark - IKImageBrowserDelegate

/**
 * ブラウザ内の画像が選択された際の処理
 */
- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser
{
	NSIndexSet *selectionIndexes = [aBrowser selectionIndexes];
	
	if ([selectionIndexes count] > 0) {
        
        NSDictionary	*screenOptions		= [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:mCurrentScreen];
        ImageItem		*imageItem			= [mImages objectAtIndex:[selectionIndexes firstIndex]];
		NSURL			*url				= [imageItem imageRepresentation];
        NSNumber		*isDirectoryFlag	= nil;
		
        if ([url getResourceValue:&isDirectoryFlag forKey:NSURLIsDirectoryKey error:nil] && ![isDirectoryFlag boolValue]) {
            
            NSError *error = nil;

            [[NSWorkspace sharedWorkspace] setDesktopImageURL:url forScreen:mCurrentScreen options:screenOptions error:&error];

			if (error) {
				[NSApp presentError:error];
            }
        }
	}
}

@end
