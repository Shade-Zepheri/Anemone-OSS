export TARGET = iphone:clang:9.3:6.0

CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Anemone
Anemone_FILES = $(wildcard *.xm)
Anemone_FRAMEWORKS = UIKit CoreGraphics QuartzCore
Anemone_PRIVATE_FRAMEWORKS = AppSupport
ifeq ($(NO_OPTITHEME),1)
	Anemone_CFLAGS += -DNO_OPTITHEME
endif
Anemone_OBJ_FILES = UIColor+HTMLColors.mm.obj
Anemone_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Anemone; sleep 0.2; sblaunch com.anemonetheming.anemone"
else
	install.exec "killall SpringBoard"
endif

#SUBPROJECTS = app uikit core recache colors dock icons iconeffects cardump mask html fonts
SUBPROJECTS = core
#ifneq ($(NO_OPTITHEME),1)
#SUBPROJECTS += anemoneoptimizer
#endif
#SUBPROJECTS += anemonefontpreviewgenerator
include $(THEOS_MAKE_PATH)/aggregate.mk
