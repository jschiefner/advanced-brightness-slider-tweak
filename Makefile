ARCHS=arm64 arm64e
TARGET := iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dimmer
Dimmer_FRAMEWORKS = UIKit QuartzCore MediaAccessibility Preferences
Dimmer_PRIVATE_FRAMEWORKS = ControlCenterUIKit AccessibilityUtilities

Dimmer_FILES = $(wildcard *.x)
Dimmer_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
