#!/bin/sh
set -e
set -x
dir="$(cd $(dirname $0) && pwd)"
lib="$(pwd)/lib"
export CFLAGS="-Os $CFLAGS"
export CFLAGS="-ffp-contract=on $CFLAGS"
cd ${dir}/fftw-${VERSION}
autoreconf -i -Wnone
BUILD="$(llvm-config --host-target)"
TARGET="${TARGET:=$BUILD}"
./configure \
    --disable-fortran \
    --disable-static \
    --enable-float \
    --enable-shared \
    --build=${BUILD} \
    --host=${TARGET} \
    $@
make
mkdir -p .destdir
make install DESTDIR=$(pwd)/.destdir
find .destdir -name '*.dylib' | while read f; do cp ${f} ${lib}/; done
find .destdir -name '*.so' | while read f; do cp ${f} ${lib}/${ABI}/; done
make clean
