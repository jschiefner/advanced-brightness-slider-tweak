ARCHS=arm64 arm64e
TARGET := iphone:clang:latest:14.5
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

SDK_PATH = $(THEOS)/sdks/iPhoneOS14.5.sdk/
SYSROOT = $(SDK_PATH)

TWEAK_NAME = AdvancedBrightnessSlider
AdvancedBrightnessSlider_FRAMEWORKS = UIKit MediaAccessibility
AdvancedBrightnessSlider_PRIVATE_FRAMEWORKS = ControlCenterUIKit AccessibilityUtilities Preferences
AdvancedBrightnessSlider_EXTRA_FRAMEWORKS += Cephei

AdvancedBrightnessSlider_FILES = $(wildcard *.x *.xm)
AdvancedBrightnessSlider_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += advancedbrightnesssliderpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
