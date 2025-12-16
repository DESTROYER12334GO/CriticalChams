TARGET := iphone:clang:latest:7.0
ARCHS = arm64

# Ignore warnings so the build finishes even if it's not perfect
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CriticalChams

CriticalChams_FILES = Tweak.xm
CriticalChams_CFLAGS = -fobjc-arc -Wno-error

include $(THEOS_MAKE_PATH)/tweak.mk
