#!/bin/sh
set -e
set -x
dir="$(cd $(dirname $0) && pwd)"
lib="$(pwd)/lib"
export CFLAGS="-Os $CFLAGS"
cd ${dir}/nu-${VERSION}
scons
cp libnu.dylib ${lib}/ || cp libnu.so ${lib}/
scons --clean
