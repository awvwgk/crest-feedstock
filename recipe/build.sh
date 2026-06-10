#!/usr/bin/env bash

set -ex

# mv $PREFIX/lib/pkgconfig/{lapack,blas}.pc $SRC_DIR

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  MESON_ARGS=${MESON_ARGS:---prefix=${PREFIX} --libdir=lib}
else
  cat > pkgconfig.ini <<EOF
[binaries]
pkgconfig = '$BUILD_PREFIX/bin/pkg-config'
EOF
  MESON_ARGS="${MESON_ARGS:---prefix=${PREFIX} --libdir=lib} --cross-file pkgconfig.ini"
fi

meson setup _build ${MESON_ARGS} \
      -Dwrap_mode=nodownload \
      -Ddefault_library=shared \
      -Dc_link_args="" \
      -Dfortran_link_args="" \
      -Dtblite:lapack=netlib \
      -Ddftd4:lapack=netlib \
      -Dmulticharge:lapack=netlib \
      -Dla_backend=netlib

meson compile -C _build
meson install -C _build --no-rebuild

# mv $SRC_DIR/{lapack,blas}.pc $PREFIX/lib/pkgconfig
# rm ${PREFIX}/bin/{mstore-info,mstore-fortranize,multicharge,dftd4}
