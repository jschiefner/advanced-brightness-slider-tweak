#import "shared.h"
#import "ABSManager.h"
#import <Cephei/HBPreferences.h>

HBPreferences* preferences;
BKSLocalDefaults* backboardDefaults = [%c(BKSLocalDefaults) new];

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	preferences = [[HBPreferences alloc] initWithIdentifier:@"com.jschiefner.advancedbrightnesssliderpreferences"];
	[preferences registerDefaults:@{@"enabled":@YES, @"threshold":@30.0f}];
	if (![preferences boolForKey:@"enabled"]) return;

	int iosVersion = [[[%c(UIDevice) currentDevice] systemVersion] intValue];
	float threshold = [preferences floatForKey:@"threshold"] / 100.0f;

	BOOL modifyAutoBrightness;
	if ([preferences objectForKey:@"modifyAutoBrightness"] == nil) {
		modifyAutoBrightness = [backboardDefaults isALSEnabled];
		[preferences setBool:modifyAutoBrightness forKey:@"modifyAutoBrightness"];
	} else {
		modifyAutoBrightness = [preferences boolForKey:@"modifyAutoBrightness"];
	}

	[[ABSManager shared] initWithAutoBrightnessEnabled:modifyAutoBrightness andIosVersion:iosVersion andThreshold:threshold];
	[preferences registerPreferenceChangeBlockForKey:@"threshold" block:^(NSString *key, id<NSCopying> _Nullable value){
		[[ABSManager shared] setThreshold:[[value copyWithZone:nil] floatValue] / 100.0f];
	}];

	if (iosVersion >= 13) initNative();
	else initNativeIOS12();

	if (%c(PrysmSliderViewController)) initPrysm();
	if (%c(SCDisplaySliderModuleViewController)) initBigSurCenter();
}

static void autoBrightnessChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	BOOL enabled = [backboardDefaults isALSEnabled];
	[ABSManager shared].modifyAutoBrightness = enabled;
	[preferences setBool:enabled forKey:@"modifyAutoBrightness"];
}

%ctor {
	// call initializer when Springboard is loaded
  CFNotificationCenterAddObserver(
		CFNotificationCenterGetLocalCenter(),
		NULL,
		&didFinishLaunching,
		(CFStringRef) UIApplicationDidFinishLaunchingNotification,
		NULL,
		CFNotificationSuspensionBehaviorDrop
	);


	// call AutoBrightness handler method when User modifies auto-brightness switch
	CFNotificationCenterAddObserver(
		CFNotificationCenterGetDarwinNotifyCenter(),
		NULL,
		autoBrightnessChanged,
		CFSTR("AXSAutoBrightnessChangedNotification"),
		NULL,
		CFNotificationSuspensionBehaviorDeliverImmediately
	);
}
