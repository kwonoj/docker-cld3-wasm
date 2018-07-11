#!/bin/bash
### Simple script wraps invocation of emcc compiler
### for wasm binary lookup in node.js

# It is important call in forms of ./build.sh -o outputfilePath ...rest,
# as we'll pick up output filename from parameter
outputFilename=$(basename $2)

echo "building binary for $@"

# invoke emscripten to build binary targets. Check Dockerfile for build targets.
em++ \
-O3 \
-Oz \
--emit-symbol-map \
--llvm-lto 1 \
-s MODULARIZE=1 \
-s NO_EXIT_RUNTIME=1 \
-s SINGLE_FILE=1 \
-s ASSERTIONS=1 \
-s ERROR_ON_UNDEFINED_SYMBOLS=1 \
-s EXPORTED_FUNCTIONS="['_dummy']" \
--bind \
./libcld3.a \
$TMPDIR/.libs/libprotobuf.a \
$@