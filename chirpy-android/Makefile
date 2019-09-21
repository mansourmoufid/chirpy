SO:=	lib/libfftw3f.so lib/libnu.so

lib/libfftw3f.so: android-env.sh ../build-fftw.sh
	VERSION=3.3.8 sh android-env.sh sh ../build-fftw.sh --enable-openmp

lib/libnu.so: android-env.sh ../build-nu.sh
	VERSION=0.7 sh android-env.sh sh ../build-nu.sh

.PHONY: so
so:
	mkdir -p lib
	$(MAKE) $(SO)

.PHONY: clean-so
clean-so:
	rm -f $(SO)
	rm -rf android-toolchain

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
apk: apk-icon love so
	mkdir -p love/src/main/assets
	cp chirpy.love love/src/main/assets/game.love
	mkdir -p app/src/main/jniLibs/armeabi-v7a
	cp lib/*.so app/src/main/jniLibs/armeabi-v7a/

.PHONY: clean-apk
clean-apk: clean-apk-icon clean-love clean-so
	rm -f app/src/main/jniLibs/armeabi-v7a/*.so
	rm -f love/src/main/assets/game.love

.PHONY: cleanup
cleanup:

.PHONY: clean
clean: cleanup clean-apk
