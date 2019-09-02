# Uncomment this if you're using STL in your project
# See CPLUSPLUS-SUPPORT.html in the NDK documentation for more information
# APP_STL := stlport_static 
APP_STL := c++_shared
APP_ABI := armeabi-v7a
APP_CPPFLAGS += -DNDEBUG
APP_CFLAGS += -fpic -frtti -fwrapv
APP_CFLAGS += -Os
#APP_CFLAGS += -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv4
#APP_CFLAGS += -mthumb
APP_LDFLAGS := -llog -landroid -lz
APP_PLATFORM := 19
NDK_TOOLCHAIN_VERSION := clang

# Fix for building on Windows
# http://stackoverflow.com/questions/12598933/ndk-build-createprocess-make-e-87-the-parameter-is-incorrect
APP_SHORT_COMMANDS := true

# APP_OPTIM := debug
