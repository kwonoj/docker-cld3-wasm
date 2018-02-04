FROM ojkwon/arch-emscripten:53e9ee60-protobuf

# Build time args
ARG BRANCH=""
ARG TARGET=""

RUN echo building for $BRANCH

# Install dependencies - enable if needed
#RUN pacman --noconfirm -Syu

# Setup output / build source path
RUN mkdir -p /out && mkdir /cld-$TARGET

# Copy source from host
COPY . /cld-$TARGET/

# Copy build script into cld3 directory
COPY ./build/build.sh ./build/embind.patch /cld-$TARGET/cld3/src/

# temp: copy makefile until upstream cld3 merges PR
COPY ./build/Makefile ./build/configure /cld-$TARGET/cld3/src/

# apply embind patch
RUN cd /cld-$TARGET/cld3/src/ && git apply embind.patch

# Set workdir to cld3
WORKDIR /cld-$TARGET/cld3/src

# Checkout branch to build
RUN git checkout $BRANCH && git show --summary

# Configure & make via emscripten
RUN protoc --version

# Run configure, we do not do it for now as protoc is already installed & available. Enable if necessary.
# RUN echo running configure && emconfigure ./configure

# Set header location to protobuf-emscripten instead of system (/usr/include) - otherwise emcc will pick up system headers
# instead of cross-compile header included in emscripten, build will fail
# For libprotobuf to link, use prebuilt via arch-emscripten under $TMPDIR/.libs
RUN echo running make && \
  emmake make \
  CXXFLAGS='--bind -pedantic'\
  PROTOBUF_INCLUDE=-I$TMPDIR/protobuf/src \
  PROTOBUF_LIBS='-L$TMPDIR/.libs -lprotobuf' libcld3.a

CMD echo dockerfile ready
