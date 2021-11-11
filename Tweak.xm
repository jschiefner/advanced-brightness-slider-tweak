#import "shared.h"
#import "ABSManager.h"
#import <Cephei/HBPreferences.h>

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	HBPreferences* preferences = [[HBPreferences alloc] initWithIdentifier:@"com.jschiefner.advancedbrightnesssliderpreferences"];
	[preferences registerDefaults:@{@"enabled":@YES, @"threshold":@30.0f,@"modifyAutoBrightness":@YES}];
	if (![preferences boolForKey:@"enabled"]) return;

	BOOL modifyAutoBrightness = [preferences boolForKey:@"modifyAutoBrightness"];
	int iosVersion = [[[%c(UIDevice) currentDevice] systemVersion] intValue];
	float threshold = [preferences floatForKey:@"threshold"] / 100.0f;
	[[ABSManager shared] initWithAutoBrightnessEnabled:modifyAutoBrightness andIosVersion:iosVersion andThreshold:threshold];

	[preferences registerPreferenceChangeBlockForKey:@"threshold" block:^(NSString *key, id<NSCopying> _Nullable value){
		[[ABSManager shared] setThreshold:[[value copyWithZone:nil] floatValue] / 100.0f];
	}];
	[preferences registerPreferenceChangeBlockForKey:@"modifyAutoBrightness" block:^(NSString *key, id<NSCopying> _Nullable value){
		[ABSManager shared].modifyAutoBrightness = [[value copyWithZone:nil] boolValue];
	}];

	if (iosVersion >= 13) initNative();
	else initNativeIOS12();

	if (%c(PrysmSliderViewController)) initPrysm();
	if (%c(SCDisplaySliderModuleViewController)) initBigSurCenter();
}

__attribute__((constructor)) static void initialize() {
  CFNotificationCenterAddObserver(
		CFNotificationCenterGetLocalCenter(),
		NULL,
		&didFinishLaunching,
		(CFStringRef) UIApplicationDidFinishLaunchingNotification,
		NULL,
		CFNotificationSuspensionBehaviorDrop
	);
}
