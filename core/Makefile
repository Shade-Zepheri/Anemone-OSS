CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AnemoneCore
AnemoneCore_FILES = ANEMSettingsManager.m Bundle.x CGImage.xm
AnemoneCore_FRAMEWORKS = CoreGraphics ImageIO
ifeq ($(NO_OPTITHEME),1)
	AnemoneCore_CFLAGS += -DNO_OPTITHEME
else
	AnemoneCore_FILES += OptithemeCheck.x
endif
ifeq ($(NO_SUBSTRATE),1)
	AnemoneCore_FILES += ../common/fishhook/fishhook.c
	AnemoneCore_CFLAGS += -DNO_SUBSTRATE
endif
AnemoneCore_LDFLAGS = -L../common -lrocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 backboardd"
