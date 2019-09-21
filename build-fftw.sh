#!/bin/sh
set -e
set -x
dir="$(cd $(dirname $0) && pwd)"
lib="$(pwd)/lib"
export CFLAGS="-Os $CFLAGS"
export CFLAGS="-ffp-contract=on $CFLAGS"
if test -z "$TARGET"; then
    TARGET="$(CC -dumpmachine)"
fi
cd ${dir}/fftw-${VERSION}
autoreconf -i -Wnone
./configure \
    --disable-fortran \
    --disable-static \
    --enable-float \
    --enable-fma \
    --enable-shared \
    --host=$TARGET \
    --target=$TARGET \
    $@
make
mkdir -p .destdir
make install DESTDIR=$(pwd)/.destdir
find .destdir -name '*.dylib' -o -name '*.so' \
    | while read f; do cp ${f} ${lib}; done
make clean
