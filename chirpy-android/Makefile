ABIS:= armeabi-v7a arm64-v8a

ifeq ("$(ABI)", "armeabi-v7a")
CFLAGS+= -mfpu=vfpv4
endif
ifeq ("$(ABI)", "arm64-v8a")
CFLAGS+= -mfpu=neon
endif

SO:= libfftw3f.so libnu.so

lib/$(ABI)/libluajit.a: android-env.sh build-luajit.sh
	VERSION=2.1.0-beta3 sh build-luajit.sh

.PHONY: luajit
luajit: android-env.sh
	for abi in $(ABIS); do \
		mkdir -p lib/$$abi; \
		ABI=$$abi $(MAKE) lib/$$abi/libluajit.a; \
	done

.PHONY: clean-luajit
clean-luajit:
	for abi in $(ABIS); do \
		rm -f lib/$$abi/libluajit.*; \
	done

lib/$(ABI)/libfftw3f.so: ../build-fftw.sh
ifeq ("$(ABI)", "armeabi-v7a")
	VERSION=3.3.8 sh ../build-fftw.sh --enable-fma --enable-openmp
else ifeq ("$(ABI)", "arm64-v8a")
	VERSION=3.3.8 sh ../build-fftw.sh --enable-neon --enable-openmp
else
	VERSION=3.3.8 sh ../build-fftw.sh --enable-openmp
endif

lib/$(ABI)/libnu.so: ../build-nu.sh
	VERSION=0.7 sh ../build-nu.sh

.PHONY: so
so: android-env.sh
	for abi in $(ABIS); do \
		mkdir -p lib/$$abi; \
		for so in $(SO); do \
			ABI="$$abi" CFLAGS="" CPPFLAGS="" LDFLAGS="" \
			sh android-env.sh $(MAKE) lib/$$abi/$$so; \
		done; \
	done

.PHONY: clean-so
clean-so:
	for abi in $(ABIS); do \
		rm -f lib/$$abi/*.so; \
	done

.PHONY: apk-icon
apk-icon:
	for x in mdpi hdpi xhdpi xxhdpi xxxhdpi; do \
		cp icon/chirpy-$$x.png \
			app/src/main/res/drawable-$$x/chirpy.png; \
	done

.PHONY: clean-apk-icon
clean-apk-icon:
	for x in mdpi hdpi xhdpi xxhdpi xxxhdpi; do \
		rm -f app/src/main/res/drawable-$$x/chirpy.png; \
	done

.PHONY: love
love:
	cd .. && MOBILE=true $(MAKE) chirpy.love
	cp ../chirpy.love .

.PHONY: clean-love
clean-love:
	rm -f chirpy.love

.PHONY: apk
apk: apk-icon love luajit so
	mkdir -p love/src/main/assets
	cp chirpy.love love/src/main/assets/game.love
	for abi in $(ABIS); do \
		mkdir -p love/src/jni/LuaJIT-2.1/android/$$abi; \
		cp lib/$$abi/libluajit.a love/src/jni/LuaJIT-2.1/android/$$abi/; \
		mkdir -p app/src/main/jniLibs/$$abi; \
		cp lib/$$abi/*.so app/src/main/jniLibs/$$abi/; \
	done

.PHONY: clean-apk
clean-apk: clean-apk-icon clean-love clean-luajit clean-so
	for abi in $(ABIS); do \
		rm -f love/src/jni/LuaJIT-2.1/android/$$abi/libluajit.*; \
		touch love/src/jni/LuaJIT-2.1/android/$$abi/libluajit.a; \
		rm -f app/src/main/jniLibs/$$abi/*.so; \
	done
	rm -f love/src/main/assets/game.love

.PHONY: cleanup
cleanup:

.PHONY: clean
clean: cleanup clean-apk
