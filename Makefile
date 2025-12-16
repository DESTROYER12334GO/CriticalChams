# Target the specific SDK we downloaded (14.5) to avoid version confusion
TARGET := iphone:clang:14.5:14.5
ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CriticalChams

CriticalChams_FILES = Tweak.xm
# -w tells the compiler to suppress ALL warnings
CriticalChams_CFLAGS = -fobjc-arc -w

include $(THEOS_MAKE_PATH)/tweak.mk
