//
//  AppController.m
//  Wallpapers
//

#import "AppController.h"
#import "ImageItem.h"
#import "FileManager.h"

@interface AppController()

@property (nonatomic,retain) NSString *imageRootPath;
@property (nonatomic,retain) NSString *categoryPath;
@property (nonatomic,retain) NSScreen *currentScreen;
@property (nonatomic,retain) NSMutableArray *images;

@end

@implementation AppController

@synthesize imageRootPath;
@synthesize categoryPath;
@synthesize currentScreen;
@synthesize images;

#pragma mark - lifecycle

// 初期設定
- (void)awakeFromNib
{
	[self initBrowser];

	FileManager *fileManager = [[FileManager alloc] init];

	// バンドルパスから初期ディレクトリの設定
	imageRootPath = [self getImagesBundle];

	// データソースの初期化
	images = [[NSMutableArray alloc] init];

	// 初期ディレクトリ内のリストを取得
    NSArray *directoryList = [[NSArray alloc] initWithArray:[fileManager getDirectoryListWithString:imageRootPath]];

	[self updateScreenList];
    [self updateScaleList];
    [self updateScreenOptions:currentScreen];
	[self updateCategoryList:directoryList];
}

// ブラウザの初期設定
- (void)initBrowser
{
	// 背景色設定
	NSColor *backColor = [NSColor colorWithCalibratedWhite:0.15 alpha:1.0];
	[imageBrowser setValue:backColor forKey:IKImageBrowserBackgroundColorKey];
}

// Images.bundle を取得
- (NSString *)getImagesBundle
{
	NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle bundlePath];

	return [NSString stringWithString:[bundlePath stringByAppendingPathComponent:IMAGES_BUNDLE]];
}

// 画面設定を取得しオプションに反映する
- (void)updateScreenOptions:(NSScreen *)aScreen
{
	if (aScreen != nil) {

		NSDictionary *screenOptions = [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:currentScreen];
		NSNumber *scaling = [screenOptions objectForKey:NSWorkspaceDesktopImageScalingKey];
        NSNumber *allowClipping = [screenOptions objectForKey:NSWorkspaceDesktopImageAllowClippingKey];
        NSInteger scaleValue;

		switch ([scaling intValue]) {
			case NSImageScaleProportionallyUpOrDown:

				scaleValue = ([allowClipping boolValue]) ? SCALE_PROPORTIONALLY_UP_OR_DOWN_CLIP : SCALE_PROPORTIONALLY_UP_OR_DOWN_NOCLIP;
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

// 画面リストの更新
- (void)updateScreenList
{
    NSMenu *screensMenu	= [[NSMenu alloc] init];
	NSInteger screenIndex = (1);

	// 画面を取得
	NSArray *screens = [NSScreen screens];

	// 各画面に名前をつけてメニューに追加する
    for (NSScreen *screen in screens) {

		BOOL isMain = [self isMainScreen:screen];
		
		NSString *screenTitle = (isMain) ?
		NSLocalizedString(@"MAIN_SCREEN", "") : [NSString stringWithFormat:@"%@ %ld", NSLocalizedString(@"SCREEN", ""), (long)screenIndex];

		// メニューに追加する
		NSMenuItem *itemTitle = [self createMenuItemWithTitle:screenTitle action:@selector(selectScreenOption:) keyEquivalent:nil targrt:self];
		[itemTitle setRepresentedObject:screen];
		[screensMenu addItem:itemTitle];

		// メイン画面の場合は選択しておく
		if (isMain) {
			[screenPopUpButton selectItem:itemTitle];
			currentScreen = screen;
		}

		screenIndex++;
	}

	[screenPopUpButton setMenu:screensMenu];
}

// スケールリストの更新
- (void)updateScaleList
{
	NSMenu *scaleMenu = [[NSMenu alloc] init];

	NSString *titleFill = NSLocalizedString(@"OPTION_PROPORTIONALLY_UP_OR_DOWN_CLIP", "");
	NSMenuItem *itemFill = [self createMenuItemWithTitle:titleFill action:@selector(selectScaleOption:) keyEquivalent:nil targrt:self];

	NSString *titleFit = NSLocalizedString(@"OPTION_PROPORTIONALLY_UP_OR_DOWN_NOCLIP", "");
	NSMenuItem *itemFit = [self createMenuItemWithTitle:titleFit action:@selector(selectScaleOption:) keyEquivalent:nil targrt:self];

	NSString *titleStretch = NSLocalizedString(@"OPTION_AXIS_INDEPENDENTRY", "");
	NSMenuItem *itemStretch = [self createMenuItemWithTitle:titleStretch action:@selector(selectScaleOption:) keyEquivalent:nil targrt:self];

	NSString *titleCenter = NSLocalizedString(@"OPTION_NONE", "");
	NSMenuItem *itemCenter = [self createMenuItemWithTitle:titleCenter action:@selector(selectScaleOption:) keyEquivalent:nil targrt:self];

    [scaleMenu addItem:itemFill];
    [scaleMenu addItem:itemFit];
    [scaleMenu addItem:itemStretch];
    [scaleMenu addItem:itemCenter];

    [scalePopUpButton setMenu:scaleMenu];
}

// カテゴリリストの更新
- (void)updateCategoryList:(NSArray *)aList
{
    NSMenu *categoryMenu = [[NSMenu alloc] init];

	// カテゴリなしを設定
	NSMenuItem *itemDef = [self createMenuItemWithTitle:NON_CATEGORY action:@selector(selectCategory:) keyEquivalent:nil targrt:self];
    [categoryMenu addItem:itemDef];

	// リストの内容を全て追加する
    for (NSString *menuName in aList) {

		NSMenuItem *item = [self createMenuItemWithTitle:menuName action:@selector(selectCategory:) keyEquivalent:nil targrt:self];
        [categoryMenu addItem:item];
    }

    [categoryPopUpButton setMenu:categoryMenu];

    [self selectCategory:nil];
}

// メニュー項目を作成する
- (NSMenuItem *)createMenuItemWithTitle:(NSString *)title action:(SEL)action keyEquivalent:(NSString *)key targrt:(id)target
{
	if (key == nil) {
		key = @"";
	}

	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:action keyEquivalent:key];
	[item setTarget:target];

	return item;
}

// メイン画面かチェックする
- (BOOL)isMainScreen:(NSScreen *)aScreen
{
	return (aScreen == [NSScreen mainScreen]);
}

// 画像追加処理を開始する
- (void)addImagesFromDirectory:(NSURL *)aURL
{
    [self lockObject:YES];

    [loadingIndicator startAnimation:self];
    [loadingIndicator setHidden:NO];

    [images removeAllObjects];

    FileManager *manager = [[FileManager alloc] init];
    NSArray *content = [manager getFileListWithURL:aURL];

    for (NSURL *imageURL in content) {
        [self addImage:imageURL];
    }

    [loadingIndicator setHidden:YES];
    [loadingIndicator stopAnimation:self];

    [self performSelectorOnMainThread:@selector(addImagesFromDirectoryDidFinish) withObject:nil waitUntilDone:NO];
}

// 画像追加処理を終了する
- (void)addImagesFromDirectoryDidFinish
{
    [imageBrowser reloadData];
    [self lockObject:NO];
}

// ブラウザに画像追加
- (void)addImage:(NSURL *)aURL
{
	ImageItem *item = [ImageItem imageItemWithContentsOfURL:aURL];
	[images addObject:item];
}

// ロック切替
- (void)lockObject:(BOOL)enable
{
    [categoryPopUpButton setEnabled:!enable];
    [screenPopUpButton setEnabled:!enable];
    [scalePopUpButton setEnabled:!enable];
    [fillColorWell setEnabled:!enable];
}

#pragma mark - Popup Selector

// カテゴリリストが選択された際の処理
- (void)selectCategory:(id)sender
{
    NSString *menuString = [categoryPopUpButton titleOfSelectedItem];

	// カテゴリなしの場合は初期ディレクトリを設定
    if ([menuString isEqualToString:NON_CATEGORY]) {
        categoryPath = imageRootPath;
    }
	else {
        categoryPath = [NSString stringWithString:[imageRootPath stringByAppendingPathComponent:menuString]];
    }

    NSURL *directoryURL = [NSURL fileURLWithPath:categoryPath];

    // バックグラウンドで画像の追加処理を開始する
    [self performSelectorInBackground:@selector(addImagesFromDirectory:) withObject:directoryURL];
}

// 画面リストが選択された際の処理
- (void)selectScreenOption:(id)sender
{
	NSMenuItem *chosenItem = (NSMenuItem *)sender;
	NSScreen *screen = [chosenItem representedObject];

	// 選択された画面アイテムを現在の画面に設定
	currentScreen = screen;

	[self updateScreenOptions:screen];
}

// スケールリストが選択された際の処理
- (void)selectScaleOption:(id)sender
{
    NSMutableDictionary *screenOptions = [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:currentScreen] mutableCopy];
    NSInteger scaling = [scalePopUpButton indexOfSelectedItem];
    NSInteger scaleValue;
    NSInteger clipValue;

    switch (scaling) {
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

#pragma mark - Action

// 背景色設定が更新された際の処理
- (IBAction)fillColorWellDidChange:(id)sender
{
	NSMutableDictionary *screenOptions = [[[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:currentScreen] mutableCopy];
	NSColor *fillColorValue	= [fillColorWell color];

	// 背景色設定を適用する
	[screenOptions setObject:fillColorValue forKey:NSWorkspaceDesktopImageFillColorKey];

    // ワークスペースに反映
	NSURL *imageURL = [[NSWorkspace sharedWorkspace] desktopImageURLForScreen:currentScreen];
	[[NSWorkspace sharedWorkspace] setDesktopImageURL:imageURL forScreen:currentScreen options:screenOptions error:nil];
}

// ズームスライダーが更新された際の処理
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

// ブラウザ内の選択が変更された際の処理
- (void)imageBrowserSelectionDidChange:(IKImageBrowserView *)aBrowser
{
	NSIndexSet *selectionIndexes = [aBrowser selectionIndexes];

	if ([selectionIndexes count] > 0) {

        NSDictionary *screenOptions = [[NSWorkspace sharedWorkspace] desktopImageOptionsForScreen:currentScreen];
        ImageItem *imageItem = [images objectAtIndex:[selectionIndexes firstIndex]];
		NSURL *url = [imageItem imageRepresentation];
        NSNumber *isDir = nil;

        if ([url getResourceValue:&isDir forKey:NSURLIsDirectoryKey error:nil] && ![isDir boolValue]) {

			NSError *error = nil;
			[[NSWorkspace sharedWorkspace] setDesktopImageURL:url forScreen:currentScreen options:screenOptions error:&error];

			if (error) {
				[NSApp presentError:error];
			}
        }
	}
}

// ダブルクリックされた場合の処理
- (void)imageBrowser:(IKImageBrowserView *)aBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index
{
	return;
}

// 右クリック次の処理
- (void)imageBrowser:(IKImageBrowserView *)aBrowser backgroundWasRightClickedWithEvent:(NSEvent *)event
{
	return;
}

@end
