#!/bin/sh
set -ex

OPENSSL_VERSION="1.0.2d"
OPENSSL_DESTINATION="`pwd`/libssl"

CURL_VERSION="7.44.0"
CURL_DESTINATION="`pwd`/libcurl"

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

# Download OpenSSL source
if [ ! -f "openssl-$OPENSSL_VERSION.tar.gz" ]
then
  curl -O "https://www.openssl.org/source/openssl-$OPENSSL_VERSION.tar.gz"
fi

# Extract OpenSSL source
rm -rf "openssl-$OPENSSL_VERSION"
tar -xvf "openssl-$OPENSSL_VERSION.tar.gz"

# Build OpenSSL
rm -rf "$OPENSSL_DESTINATION"
pushd "openssl-$OPENSSL_VERSION"
./Configure android-armv7 --prefix="$OPENSSL_DESTINATION" -shared
make -j4
make install_sw
popd
rm -rf "$OPENSSL_DESTINATION/bin" "$OPENSSL_DESTINATION/ssl" "$OPENSSL_DESTINATION/lib/engines" "$OPENSSL_DESTINATION/lib/pkgconfig"

# Download cURL source
if [ ! -f "curl-$CURL_VERSION.tar.gz" ]
then
  curl -L -O "https://github.com/bagder/curl/releases/download/curl-7_44_0/curl-$CURL_VERSION.tar.gz"
fi

# Extract cURL source
rm -rf "curl-$CURL_VERSION"
tar -xvf "curl-$CURL_VERSION.tar.gz"

# Build cURL
rm -rf "$CURL_DESTINATION"
pushd "curl-$CURL_VERSION"
./configure --prefix "$CURL_DESTINATION" --host="arm-linux-androideabi" --enable-static --enable-shared \
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
  --with-ssl="$OPENSSL_DESTINATION" --without-libssh2
make -j4
make install
popd
rm -rf "$CURL_DESTINATION/bin" "$CURL_DESTINATION/share" "$CURL_DESTINATION/lib/libcurl.la" "$CURL_DESTINATION/lib/pkgconfig"

# Clean up
rm -rf "curl-$CURL_VERSION"
rm -rf "openssl-$OPENSSL_VERSION"
