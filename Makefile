ARCHS=arm64 arm64e
TARGET := iphone:clang:14.5:14.5
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AdvancedBrightnessSlider
AdvancedBrightnessSlider_FRAMEWORKS = UIKit MediaAccessibility
AdvancedBrightnessSlider_PRIVATE_FRAMEWORKS = ControlCenterUIKit AccessibilityUtilities
AdvancedBrightnessSlider_EXTRA_FRAMEWORKS += Cephei

AdvancedBrightnessSlider_FILES = $(wildcard *.x *.xm)
AdvancedBrightnessSlider_CFLAGS = -fobjc-arc -Wno-c++11-extensions

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += advancedbrightnesssliderpreferences
include $(THEOS_MAKE_PATH)/aggregate.mk
