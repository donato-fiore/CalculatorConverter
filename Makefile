TARGET := iphone:clang:16.5:14.0
INSTALL_TARGET_PROCESSES = Calculator

THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CalculatorConverter

CalculatorConverter_FILES = $(shell find . \( -path "*/.theos/*" \) -prune -o \( -name "*.m" -o -name "*.x*" -o -name "*.swift" -o -name "*.mm" \) -print)
CalculatorConverter_PRIVATE_FRAMEWORKS = Calculate
CalculatorConverter_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/include

include $(THEOS_MAKE_PATH)/tweak.mk
