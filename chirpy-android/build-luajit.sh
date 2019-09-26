#!/bin/sh
set -e
set -x
lib="$(pwd)/lib"
CC="cc"
LD="ld"
export CC="$(which ${CC})"
export LD="$(which ${LD})"
export HOST_CC="${CC}"
export HOST_LD="${LD}"
case "${ABI}" in
    "armeabi-v7a")
        CFLAGS="-m32 ${CFLAGS}"
        LDFLAGS="-m32 ${LDFLAGS}"
        ;;
    "arm64-v8a")
        CFLAGS="-m64 ${CFLAGS}"
        LDFLAGS="-m64 ${LDFLAGS}"
        ;;
    *)
        ;;
esac
export HOST_CFLAGS="${CFLAGS}"
export HOST_LDFLAGS="${LDFLAGS}"
export HOST_SYS="$(uname -s)"
export TARGET_SYS="Linux"
sh android-env.sh make -C LuaJIT-${VERSION} clean
sh android-env.sh make -C LuaJIT-${VERSION}
cp LuaJIT-${VERSION}/src/libluajit.a ${lib}/${ABI}/
cp LuaJIT-${VERSION}/src/libluajit.so ${lib}/${ABI}/
