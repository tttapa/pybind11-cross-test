#!/usr/bin/env bash
cd "$( dirname "${BASH_SOURCE[0]}" )"

set -ex

# Command line arguments
PYTHON_VERSION=${1:-3.13}
HOST_TRIPLE=${2:-aarch64-linux-gnu}

# Process Python verions
IFS='.' read -r PYTHON_MAJOR PYTHON_MINOR PYTHON_PATCH_PRE <<< "$PYTHON_VERSION"
if [ -z "$PYTHON_PATCH_PRE" ]; then
    case "$PYTHON_MAJOR.$PYTHON_MINOR" in
        3.6) PYTHON_PATCH_PRE=15 ;;
        3.7) PYTHON_PATCH_PRE=17 ;;
        3.8) PYTHON_PATCH_PRE=19 ;;
        3.9) PYTHON_PATCH_PRE=19 ;;
        3.10) PYTHON_PATCH_PRE=14 ;;
        3.11) PYTHON_PATCH_PRE=8 ;;
        3.12) PYTHON_PATCH_PRE=2 ;;
        3.13) PYTHON_PATCH_PRE=0a5 ;;
    esac
fi
PYTHON_PATCH="${PYTHON_PATCH_PRE%%[^0-9]*}"
PYTHON_PRERELEASE="${PYTHON_PATCH_PRE#"$PYTHON_PATCH"}"
PYTHON_VERSION="$PYTHON_MAJOR.$PYTHON_MINOR.$PYTHON_PATCH"

# Prepare build directories
DOWNLOAD_DIR="$PWD/download"
BUILD_DIR="$PWD/build"
INSTALL_DIR="$PWD/staging/python$PYTHON_MAJOR.$PYTHON_MINOR"

mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

# Download and build Zlib
ZLIB_VERSION=1.3
ZLIB_FULL=zlib-$ZLIB_VERSION
ZLIB_URL=https://github.com/madler/zlib/releases/download/

[ -e "$DOWNLOAD_DIR/$ZLIB_FULL.tar.gz" ] || \
wget "$ZLIB_URL/v$ZLIB_VERSION/$ZLIB_FULL.tar.gz" -O "$DOWNLOAD_DIR/$ZLIB_FULL.tar.gz"
tar xzf "$DOWNLOAD_DIR/$ZLIB_FULL.tar.gz" -C "$BUILD_DIR"

pushd "$BUILD_DIR/$ZLIB_FULL"
CC="$HOST_TRIPLE-gcc" \
LD="$HOST_TRIPLE-ld" \
./configure \
    --prefix="$INSTALL_DIR/usr/local"
make -j$(nproc)
make install
popd

# Download and build Python
PYTHON_FULL="Python-$PYTHON_VERSION$PYTHON_PRERELEASE"
PYTHON_URL="https://www.python.org/ftp/python"

[ -e "$DOWNLOAD_DIR/$PYTHON_FULL.tgz" ] || \
wget "$PYTHON_URL/$PYTHON_VERSION/$PYTHON_FULL.tgz" -O "$DOWNLOAD_DIR/$PYTHON_FULL.tgz"
tar xzf "$DOWNLOAD_DIR/$PYTHON_FULL.tgz" -C "$BUILD_DIR"

pushd "$BUILD_DIR/$PYTHON_FULL"
export CONFIG_SITE="$PWD/config.site"
cat << EOF > "$CONFIG_SITE"
ac_cv_file__dev_ptmx=yes
ac_cv_file__dev_ptc=no
EOF
PKG_CONFIG_LIBDIR="" \
OPENSSL_LDFLAGS="" OPENSSL_LIBS=""; OPENSSL_INCLUDES="" \
ZLIB_CFLAGS="-I $INSTALL_DIR/usr/local/include" \
ZLIB_LIBS="-L $INSTALL_DIR/usr/local/lib -lz" \
./configure \
    --enable-ipv6 \
    --enable-shared \
    --disable-test-modules \
    --build="$(gcc -print-multiarch)" \
    --with-build-python=python$PYTHON_MAJOR.$PYTHON_MINOR \
    --host="$HOST_TRIPLE" \
    --prefix="/usr/local" \
    --with-pkg-config=no
make -j$(nproc)
make altinstall DESTDIR="$INSTALL_DIR"
popd
