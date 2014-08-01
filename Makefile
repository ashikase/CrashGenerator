APPLICATION_NAME = CrashGenerator
PKG_ID = jp.ashikase.crashgenerator

CrashGenerator_FILES = \
    Common/Classes/LRFLabel.m \
    Common/Classes/LRFStatusPopup.m \
    ApplicationDelegate.m \
    RootViewController.m \
    main.m
CrashGenerator_CFLAGS = -I$(THEOS_PROJECT_DIR)/Common -I$(THEOS_PROJECT_DIR)/Common/Classes -include firmware.h
CrashGenerator_FRAMEWORKS = UIKit CoreGraphics

export ARCHS = armv6
export TARGET = iphone:clang
export TARGET_IPHONEOS_DEPLOYMENT_VERSION = 3.0

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk

after-install::
	- ssh idevice killall CrashGenerator

distclean: clean
	- rm -f $(THEOS_PROJECT_DIR)/$(PKG_ID)*.deb
	- rm -f $(THEOS_PROJECT_DIR)/.theos/packages/*
