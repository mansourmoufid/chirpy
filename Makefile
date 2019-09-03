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

SO:=	lib/libfftw3f.so lib/libnu.so

.PHONY: so
so: $(SO)

lib/libfftw3f.so: android-env.sh build-fftw.sh
	VERSION=3.3.4 sh android-env.sh sh build-fftw.sh --enable-openmp

lib/libnu.so: android-env.sh build-nu.sh
	VERSION=0.6 sh android-env.sh sh build-nu.sh

.PHONY: love
love: chirpy.love

.PHONY: icon
icon:
	for x in mdpi hdpi xhdpi xxhdpi xxxhdpi; do \
		cp icon/chirpy-$$x.png \
			chirpy-android/app/src/main/res/drawable-$$x/chirpy.png; \
	done

.PHONY: apk
apk: $(SO) icon
	MOBILE=true $(MAKE) chirpy.love
	mkdir -p chirpy-android/app/src/main/jniLibs/armeabi-v7a
	cp lib/*.so chirpy-android/app/src/main/jniLibs/armeabi-v7a/
	mkdir -p chirpy-android/love/src/main/assets
	cp chirpy.love chirpy-android/love/src/main/assets/game.love

.PHONY: mobile.lua
mobile.lua:
ifdef MOBILE
	echo 'return true' > mobile.lua
else
	echo 'return false' > mobile.lua
endif

chirpy.love: main.lua $(DEPENDS) $(FONTS)
	zip chirpy.zip main.lua $(DEPENDS) $(FONTS)
	cp chirpy.zip chirpy.love

.PHONY: cleanup
cleanup:
	rm -f chirpy.zip
	rm -rf android-toolchain

.PHONY: clean
clean: cleanup
	rm -f chirpy.love
	rm -f $(SO)
	for x in mdpi hdpi xhdpi xxhdpi xxxhdpi; do \
		rm -f chirpy-android/app/src/main/res/drawable-$$x/chirpy.png; \
	done
	for so in lib/*.so; do \
		rm -f chirpy-android/app/src/main/jniLibs/armeabi-v7a/$$so; \
	done
	rm -f chirpy-android/love/src/main/assets/game.love

.PHONY: check
check: $(DEPENDS)
	luacheck main.lua $(DEPENDS)
