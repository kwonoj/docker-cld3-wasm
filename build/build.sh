#!/bin/bash
### Simple script wraps invocation of emcc compiler
### for wasm binary lookup in node.js

# It is important call in forms of ./build.sh -o outputfilePath ...rest,
# as we'll pick up output filename from parameter
outputFilename=$(basename $2)

echo "building binary for $@"

# functions to be exported from cld3
CLD_EXPORT_FUNCTIONS="[\
'_get_SizeLanguageResult',\
'_get_UnknownIdentifier',\
'_get_MinNumBytesDefault',\
'_get_MaxNumBytesDefault',\
'_get_MaxNumBytesInput',\
'_Cld_create',\
'_Cld_destroy',\
'_Cld_findLanguage',\
'_Cld_findTopNMostFreqLangs']"

# additional runtime helper from emscripten
EXPORT_RUNTIME="[\
'cwrap',\
'stringToUTF8',\
'allocateUTF8', \
'getValue',\
'setValue',\
'Pointer_stringify']"

# invoke emscripten to build binary targets. Check Dockerfile for build targets.
em++ \
-O2 \
--emit-symbol-map \
--llvm-lto 1 \
-s ENVIRONMENT=web,node \
-s MODULARIZE=1 \
-s NO_EXIT_RUNTIME=1 \
-s ASSERTIONS=1 \
-s DYNAMIC_EXECUTION=0 \
-s SINGLE_FILE=1 \
-s ERROR_ON_UNDEFINED_SYMBOLS=1 \
-s EXPORTED_FUNCTIONS="$CLD_EXPORT_FUNCTIONS" \
-s EXTRA_EXPORTED_RUNTIME_METHODS="$EXPORT_RUNTIME" \
./libcld3.a \
$TMPDIR/.libs/libprotobuf.a \
$@