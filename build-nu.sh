#!/bin/sh
set -e
set -x
export CFLAGS="-Os $CFLAGS"
cd nu-${VERSION}
scons
cp libnu.dylib ../lib/ || cp libnu.so ../lib/
scons --clean
