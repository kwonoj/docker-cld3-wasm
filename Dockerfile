FROM ojkwon/arch-emscripten:f7961a11-protobuf

# Build time args
ARG BRANCH=""
ARG TARGET=""
ARG PROTOBUF_VERSION=""

RUN echo building for $BRANCH

# Install dependencies - enable if needed
#RUN pacman --noconfirm -Syu

# Setup output / build source path
RUN mkdir -p /out && mkdir /cld-$TARGET

# Copy source from host
COPY . /cld-$TARGET/

# Copy build script into cld3 directory
COPY ./build/build.sh ./build/embind.patch /cld-$TARGET/cld3/src/

# temp: copy makefile until upstream merges PR
COPY ./build/Makefile ./build/configure /cld-$TARGET/cld3/src/

# apply embind patch
RUN cd /cld-$TARGET/cld3/src/ && git apply embind.patch

# Copy prebuilt protobuf-emscripten libraries to link against cld3
RUN cp -r $TMPDIR/.libs /cld-$TARGET/cld3/src/ && \
    mv /cld-$TARGET/cld3/src/.libs/libprotobuf.so        /cld-$TARGET/cld3/src/.libs/libprotobuf.bc && \
    mv /cld-$TARGET/cld3/src/.libs/libprotobuf.so.15     /cld-$TARGET/cld3/src/.libs/libprotobuf.bc.15 && \
    mv /cld-$TARGET/cld3/src/.libs/libprotobuf.so.15.0.1 /cld-$TARGET/cld3/src/.libs/libprotobuf.bc.15.0.1 && \
    cp -r $TMPDIR/.libs /cld-$TARGET/cld3/src/

# Set workdir to cld3
WORKDIR /cld-$TARGET/cld3/src

# Checkout branch to build
RUN git checkout $BRANCH && git show --summary

# Configure & make via emscripten
RUN protoc --version

# Run configure, we do not do it for now as protoc is already installed & available. Enable if necessary.
#RUN echo running configure && emconfigure ./configure

# set header location to protobuf-emscripten instead of system (/usr/include) - otherwise emcc will pick up system headers
# instead of cross-compile header included in emscripten, build will fail
RUN echo running make && \
  emmake make \
  CXXFLAGS='--bind -pedantic'\
  PROTOBUF_INCLUDE=-I$TMPDIR/protobuf/src \
  PROTOBUF_LIBS='-L/cld-$TARGET/protobuf/src/.libs -lprotobuf' libcld3.a

CMD echo dockerfile ready