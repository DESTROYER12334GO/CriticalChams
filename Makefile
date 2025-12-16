TARGET := iphone:clang:latest:7.0
ARCHS = arm64

# Ignore all warnings
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CriticalChams

# WILDCARD: This grabs Tweak.xm, tweak.xm, or whatever you named it.
CriticalChams_FILES = $(wildcard *.xm)

# Force the compiler to be lenient
CriticalChams_CFLAGS = -fobjc-arc -w -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk
