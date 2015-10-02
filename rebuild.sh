#!/bin/sh
set -ex

VERSION="7.44.0"

DESTINATION="`pwd`/libcurl"

export ANDROID_NDK="$HOME/Library/Android/sdk/ndk-bundle"

export NDK_PLATFORM="$ANDROID_NDK/platforms/android-21/arch-arm"
export NDK_TOOLCHAIN="$ANDROID_NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64"

export CC="$NDK_TOOLCHAIN/bin/arm-linux-androideabi-gcc --sysroot=$NDK_PLATFORM"
export CPP="$NDK_TOOLCHAIN/bin/arm-linux-androideabi-cpp --sysroot=$NDK_PLATFORM"
export CXX="$NDK_TOOLCHAIN/bin/arm-linux-androideabi-g++ --sysroot=$NDK_PLATFORM"
export CXXCPP="$NDK_TOOLCHAIN/bin/arm-linux-androideabi-cpp --sysroot=$NDK_PLATFORM"
export LD="$NDK_TOOLCHAIN/bin/arm-linux-androideabi-ld --sysroot=$NDK_PLATFORM"
export AR="$NDK_TOOLCHAIN/bin/arm-linux-androideabi-ar"
export RANLIB="$NDK_TOOLCHAIN/bin/arm-linux-androideabi-ranlib"

# Download source
if [ ! -f "curl-$VERSION.tar.gz" ]
then
  curl -L -O "https://github.com/bagder/curl/releases/download/curl-7_44_0/curl-$VERSION.tar.gz"
fi

# Extract source
rm -rf "curl-$VERSION"
tar -xvf "curl-$VERSION.tar.gz"

# Build library
rm -rf "$DESTINATION"
pushd "curl-$VERSION"
./configure --prefix "$DESTINATION" --host="arm-linux-androideabi" --enable-static --disable-shared \
  --disable-debug --disable-curldebug --enable-verbose \
  --enable-threaded-resolver --disable-ares \
  --enable-ipv6 \
  --enable-crypto-auth \
  --enable-http \
  --enable-proxy \
  --disable-ftp \
  --disable-file \
  --disable-ldap \
  --disable-ldaps \
  --disable-rtsp \
  --disable-dict \
  --disable-telnet \
  --disable-tftp \
  --disable-pop3 \
  --disable-imap \
  --disable-smb \
  --disable-smtp \
  --disable-gopher \
  --disable-manual \
  --disable-sspi \
  --without-ssl --without-libssh2
make -j4
make install
popd
rm -rf "$DESTINATION/bin" "$DESTINATION/share" "$DESTINATION/lib/libcurl.la" "$DESTINATION/lib/pkgconfig"

# Clean up
rm -rf "curl-$VERSION"
