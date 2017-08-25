#!/bin/bash
### Simple script wraps invocation of emcc compiler, also prepares preprocessor
### for wasm binary lookup in node.js

# It is important call in forms of ./build.sh -o outputfilePath ...rest,
# as we'll pick up output filename from parameter
outputFilename=$(basename $2)

# Injecting -o option's filename into each targets preprocessor.
# sed -i -e "s/___wasm_binary_name___/${outputFilename%.*}/g" ./preprocessor.js

echo "building binary for $@"

# invoke emscripten to build binary targets. Check Dockerfile for build targets.
em++ \
-O3 \
-Oz \
--llvm-lto 1 \
-s MODULARIZE=1 \
-s NO_EXIT_RUNTIME=1 \
-s ERROR_ON_UNDEFINED_SYMBOLS=1 \
--bind \
./.libs/libprotobuf.bc \
./libcld3.a \
-I $TMPDIR/protobuf-emscripten/3.1.0/src/.libs/libprotobuf.so.11.0.0 \
-s EXPORTED_FUNCTIONS="['_dummy']" \
--pre-js ./preprocessor.js \
$@

#--closure 1 \