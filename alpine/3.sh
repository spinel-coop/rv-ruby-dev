#!/bin/sh

./configure "--prefix=${INSTALL_PREFIX}" \
  "--build=${BUILD_TRIPLE}" \
  --enable-load-relative \
  --disable-shared \
  --enable-yjit \
  --disable-install-doc \
  --disable-install-rdoc \
  --disable-dependency-tracking \
  --with-static-linked-ext \
  --with-libyaml-dir="${STATIC_DIR}" \
  --with-libffi-dir="${STATIC_DIR}" \
  --with-zlib-dir="${STATIC_DIR}" \
  --with-readline-dir="${STATIC_DIR}" \
  --with-gdbm-dir="${STATIC_DIR}" \
  --with-out-ext=win32,win32ole \
  --without-gmp
