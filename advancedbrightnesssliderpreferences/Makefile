ARCHS=arm64 arm64e
TARGET := iphone:clang:latest:14.5

include $(THEOS)/makefiles/common.mk

SDK_PATH = $(THEOS)/sdks/iPhoneOS14.5.sdk/
SYSROOT = $(SDK_PATH)

BUNDLE_NAME = AdvancedBrightnessSliderPreferences

AdvancedBrightnessSliderPreferences_FILES = ABSRootListController.xm
AdvancedBrightnessSliderPreferences_FRAMEWORKS = UIKit
AdvancedBrightnessSliderPreferences_PRIVATE_FRAMEWORKS = Preferences
AdvancedBrightnessSliderPreferences_EXTRA_FRAMEWORKS += Cephei
AdvancedBrightnessSliderPreferences_INSTALL_PATH = /Library/PreferenceBundles
AdvancedBrightnessSliderPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
