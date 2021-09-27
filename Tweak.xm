#import "shared.h"
#import "ABSManager.h"

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	NSDictionary* bundleDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.jschiefner.advancedbrightnesssliderpreferences"];
	if (bundleDefaults == nil) bundleDefaults = @{@"enabled":@YES, @"threshold":@30.0f,@"modifyAutoBrightness":@YES};
	BOOL enabled = [bundleDefaults objectForKey:@"enabled"] == nil ? YES : [[bundleDefaults objectForKey:@"enabled"] boolValue];
	if (!enabled) return;

	BOOL shouldModifyAutoBrightness = [bundleDefaults objectForKey:@"modifyAutoBrightness"] == nil ? YES : [[bundleDefaults objectForKey:@"modifyAutoBrightness"] boolValue];
	int iosVersion = [[[%c(UIDevice) currentDevice] systemVersion] intValue];
	// example values in the code assume the threshold to be set to 30%
	float threshold = [bundleDefaults objectForKey:@"threshold"] == nil ? 0.3f : [[bundleDefaults objectForKey:@"threshold"] floatValue] / 100.0f;
	[[ABSManager shared] initWithAutoBrightnessEnabled:shouldModifyAutoBrightness andIosVersion:iosVersion andThreshold:threshold];

	if (NSClassFromString(@"PrysmSliderViewController")) initPrysm();
	initNative();
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
