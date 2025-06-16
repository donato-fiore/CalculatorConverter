TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = Calculator

THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CalculatorConverter

CalculatorConverter_FILES = Tweak.x $(wildcard *.m) $(wildcard CalculateUnits/*.m)
CalculatorConverter_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/include

include $(THEOS_MAKE_PATH)/tweak.mk
