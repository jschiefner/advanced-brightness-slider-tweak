ARCHS=arm64 arm64e
TARGET := iphone:clang:14.5:14.5

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AdvancedBrightnessSliderPreferences

AdvancedBrightnessSliderPreferences_FILES = ABSRootListController.xm
AdvancedBrightnessSliderPreferences_FRAMEWORKS = UIKit
AdvancedBrightnessSliderPreferences_PRIVATE_FRAMEWORKS = Preferences
AdvancedBrightnessSliderPreferences_EXTRA_FRAMEWORKS += Cephei
AdvancedBrightnessSliderPreferences_INSTALL_PATH = /Library/PreferenceBundles
AdvancedBrightnessSliderPreferences_CFLAGS = -fobjc-arc -Wno-c++11-extensions

include $(THEOS_MAKE_PATH)/bundle.mk
