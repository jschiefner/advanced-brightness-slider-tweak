ARCHS=arm64 arm64e
TARGET := iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AdvancedBrightnessSliderPreferences

AdvancedBrightnessSliderPreferences_FILES = ABSRootListController.xm
AdvancedBrightnessSliderPreferences_FRAMEWORKS = UIKit
AdvancedBrightnessSliderPreferences_PRIVATE_FRAMEWORKS = Preferences
AdvancedBrightnessSliderPreferences_EXTRA_FRAMEWORKS += Cephei
AdvancedBrightnessSliderPreferences_INSTALL_PATH = /Library/PreferenceBundles
AdvancedBrightnessSliderPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
