#!/bin/sh
set -e
set -x
dir="$(cd $(dirname $0) && pwd)"
lib="$(pwd)/lib"
export CFLAGS="-Os $CFLAGS"
cd ${dir}/nu-${VERSION}
scons
find . -name '*.dylib' | while read f; do cp ${f} ${lib}/; done
find . -name '*.so' | while read f; do cp ${f} ${lib}/${ABI}/; done
scons --clean
