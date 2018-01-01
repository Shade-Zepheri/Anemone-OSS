#import "core/ANEMSettingsManager.h"
#import <AppSupport/CPDistributedMessagingCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <dlfcn.h>
#import <objc/runtime.h>

@interface CPBitmapStore : NSObject
- (void)purge;
@end

@interface _UIStatusBarCache : NSObject
+ (instancetype)sharedInstance;
@end

@interface SBIconView : UIView
- (void)prepareForReuse;
@end

@interface SBIconListView : UIView
- (void)showAllIcons;
@end

@interface SBRootFolderView : UIView {
	UIView *_dockView;
	SBIconListView *_dockListView;
}
- (SBIconListView *)currentIconListView;
- (void)resetIconListViews;
- (NSUInteger)iconListViewCount;
- (NSUInteger)currentPageIndex;
- (NSArray *)iconListViews;
@end

@interface SBRootFolderController : NSObject
- (SBRootFolderView *)contentView;
@end

@interface SBIconController : NSObject {
	SBRootFolderController *_rootFolderController;
}
+ (instancetype)sharedInstance;
@end

@interface SBIconListPageControl : UIPageControl
- (void)reloadAllDots;
@end

@interface AnemoneNoRespringServer : NSObject {
	CPDistributedMessagingCenter *_server;
}

+ (instancetype)defaultReloadServer;

@end

@implementation AnemoneNoRespringServer

+ (instancetype)defaultReloadServer {
	static AnemoneNoRespringServer *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (instancetype)init {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/AnemoneCore.dylib", RTLD_NOW);
	self = [super init];
	if (self) {
		_server = [%c(CPDistributedMessagingCenter) centerNamed:@"com.anemonetheming.anemone.springboard"];
		rocketbootstrap_distributedmessagingcenter_apply(_server);
		[_server runServerOnCurrentThread];
		[_server registerForMessageName:@"forceReloadNow" target:self selector:@selector(forceReloadNow)];
		[_server registerForMessageName:@"ping" target:self selector:@selector(ping)];
	}

	return self;
}

- (NSDictionary *)ping {
	return @{@"pong" : @YES};
}

- (void)forceReloadNow {
	[[%c(ANEMSettingsManager) sharedManager] forceReloadNow];

#ifndef NO_OPTITHEME
	[[%c(ANEMSettingsManager) sharedManager] setOptithemeEnabled:YES];
#endif

	CPBitmapStore *statusBarCacheStore = [[%c(_UIStatusBarCache) sharedInstance] valueForKey:@"_store"];
	[statusBarCacheStore purge];

	SBIconController *iconController = [%c(SBIconController) sharedInstance];
	SBRootFolderController *rootFolderController = [iconController valueForKey:@"_rootFolderController"];

	//[[rootFolderController contentView] resetIconListViews]; // Fallback, but slow
	SBRootFolderView *rootFolderView = [rootFolderController contentView];
	SBIconListView *dockListView = [rootFolderView valueForKey:@"_dockListView"];
	for (SBIconView *iconView in [dockListView subviews]) {
		if ([iconView respondsToSelector:@selector(prepareForReuse)]) {
			[iconView prepareForReuse];
		}
	}
	[dockListView showAllIcons];

	[[rootFolderView currentIconListView] showAllIcons];

	SBIconListPageControl *pageControl = [rootFolderView valueForKey:@"_pageControl"];
	if ([pageControl respondsToSelector:@selector(reloadAllDots)]) {
		[pageControl reloadAllDots];
	}

	NSUInteger listViewCount = [rootFolderView iconListViewCount];
	NSUInteger currentPageIndex = [rootFolderView currentPageIndex];
	NSArray *iconLists = [rootFolderView iconListViews];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if (currentPageIndex < listViewCount-1) {
			SBIconListView *iconListView = [iconLists objectAtIndex:currentPageIndex+1];
			for (SBIconView *iconView in [iconListView subviews]) {
				if ([iconView respondsToSelector:@selector(prepareForReuse)]) {
					[iconView prepareForReuse];
				}
			}
			[iconListView showAllIcons];
		}
		if (currentPageIndex > 0) {
			SBIconListView *iconListView = [iconLists objectAtIndex:currentPageIndex-1];
			for (SBIconView *iconView in [iconListView subviews]){
				if ([iconView respondsToSelector:@selector(prepareForReuse)]) {
					[iconView prepareForReuse];
				}
			}
			[iconListView showAllIcons];
		}
	});

	UIView *dockView = [rootFolderView valueForKey:@"_dockView"];
	[dockView layoutSubviews];
}
@end

static inline void initializeTweak(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	if (kCFCoreFoundationVersionNumber > MaxSupportedCFVersion) {
		return;
	}

	dlopen("/System/Library/PrivateFrameworks/AppSupport.framework/AppSupport", RTLD_NOW);
	[AnemoneNoRespringServer defaultReloadServer];
}

%ctor {
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, &initializeTweak, CFSTR("SBSpringBoardDidLaunchNotification"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}
