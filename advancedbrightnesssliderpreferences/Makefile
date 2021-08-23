TARGET := iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AdvancedBrightnessSliderPreferences

AdvancedBrightnessSliderPreferences_FILES = ABSRootListController.m
AdvancedBrightnessSliderPreferences_FRAMEWORKS = UIKit
AdvancedBrightnessSliderPreferences_PRIVATE_FRAMEWORKS = Preferences
AdvancedBrightnessSliderPreferences_INSTALL_PATH = /Library/PreferenceBundles
AdvancedBrightnessSliderPreferences_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
