#!/bin/bash
# Script to build and install wxWidgets, with our custom tweaks patch.

set -e

WX_VERSION=3.0.0
CONFIGURATION=Release

if [[ -z "$WX_VERSION" ]]; then
  echo "First argument must be set to the wxWindows version"
  exit 1
fi

INSTALL_PATH="$HOME/wxWidgets-$WX_VERSION"
mkdir -p $INSTALL_PATH

WX_CONFIGURE_FLAGS="\
  --disable-shared \
  --enable-compat28 \
  --with-macosx-version-min=10.10 \
  --with-libpng=builtin \
  --with-libjpeg=builtin \
  --with-libtiff=builtin \
  --with-liblzma=builtin \
  CFLAGS=-fvisibility-inlines-hidden \
  CXXFLAGS='-fvisibility-inlines-hidden -stdlib=libc++' \
  CPPFLAGS='-fvisibility-inlines-hidden -stdlib=libc++' \
  OBJCFLAGS=-fvisibility-inlines-hidden \
  OBJCXXFLAGS='-fvisibility-inlines-hidden -stdlib=libc++' \
  LDFLAGS=-stdlib=libc++"
WX_MAKE_FLAGS="SHARED=0"

WX_MAKE_FLAGS="$WX_MAKE_FLAGS BUILD=release"

"Building wxWidgets version $WX_VERSION for configuration: $CONFIGURATION"
mkdir -p $INSTALL_PATH

BUILD_COMMAND="sed -e 's/WXWIN_COMPATIBILITY_2_8 0/WXWIN_COMPATIBILITY_2_8 1/' -i include/wx/msw/setup.h"
BUILD_COMMAND="$BUILD_COMMAND && cd build/msw && nmake.exe -f makefile.vc $WX_MAKE_FLAGS"
BUILD_COMMAND="$BUILD_COMMAND && cp -a ../../lib ../../include $INSTALL_PATH"

# Check to see if the cache directory is empty
if [ ! -d "$INSTALL_PATH/lib" ]; then
  curl -fsSL -o wxWidgets-$WX_VERSION.tar.bz2 https://github.com/wxWidgets/wxWidgets/releases/download/v$WX_VERSION/wxWidgets-$WX_VERSION.tar.bz2
  tar -xjf wxWidgets-$WX_VERSION.tar.bz2
  cd wxWidgets-$WX_VERSION
  patch -p1 -i ../wxaui-tweaks.patch
  eval $BUILD_COMMAND
else
  echo "Using cached directory."
fi
