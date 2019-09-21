DEPENDS:= \
		array.lua \
		button.lua \
		chirp.lua \
		chirpy.lua \
		fibonacci.lua \
		libfftw/*.lua \
		libnu.lua \
		load.lua \
		xcor.lua \
		mobile.lua \
		play.lua \
		pointer.lua \
		read.lua \
		str.lua \
		window.lua

FONTS:= fonts/DejaVuSans.ttf

.PHONY: all
all: apk

.PHONY: love
love: chirpy.love

.PHONY: clean-love
clean-love:
	rm -f chirpy.love

.PHONY: mobile.lua
mobile.lua:
ifdef MOBILE
	echo 'return true' > mobile.lua
else
	echo 'return false' > mobile.lua
endif

chirpy.love: main.lua mobile.lua $(DEPENDS) $(FONTS)
	zip chirpy.zip main.lua $(DEPENDS) $(FONTS)
	cp chirpy.zip chirpy.love

.PHONY: apk
apk:
	cd chirpy-android && $(MAKE) apk

.PHONY: clean-apk
clean-apk:
	cd chirpy-android && $(MAKE) clean

.PHONY: cleanup
cleanup:
	rm -f chirpy.zip
	rm -f mobile.lua

.PHONY: clean
clean: cleanup clean-apk clean-love

.PHONY: check
check: $(DEPENDS)
	luacheck main.lua $(DEPENDS)
