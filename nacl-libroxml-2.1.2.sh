#!/bin/bash
# Copyright (c) 2012 Leon Pajk All rights reserved.
# Use of this source code is governed by a LGPL-style license that can be
# found in the LICENSE file.

# nacl-libroxml-2.1.2.sh
#
# usage:  nacl-libroxml-2.1.2.sh
#
# this script downloads, patches, and builds libroxml for Native Client
#

readonly URL=http://libroxml.googlecode.com/files/libroxml-2.1.2.tar.gz
readonly PATCH_FILE=nacl-libroxml-2.1.2.patch
readonly PACKAGE_NAME=libroxml-2.1.2

# Set evironment variable for a 32-bit or 64-bit build platform
NACL_PACKAGES_BITSIZE=32

source ../../build_tools/common.sh

CustomConfigureStep() {
  Banner "Configuring ${PACKAGE_NAME}"
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}
  # export the nacl tools
  export CC=${NACLCC}
  export CXX=${NACLCXX}
  export AR=${NACLAR}
  export RANLIB=${NACLRANLIB}
  export PKG_CONFIG_PATH=${NACL_SDK_USR_LIB}/pkgconfig
  export PKG_CONFIG_LIBDIR=${NACL_SDK_USR_LIB}
  export FREETYPE_CONFIG=${NACL_SDK_USR_BIN}/freetype-config
  export PATH=${NACL_BIN_PATH}:${PATH};
  ChangeDir ${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}
  Remove ${PACKAGE_NAME}-build
  MakeDir ${PACKAGE_NAME}-build
  cd ${PACKAGE_NAME}-build
}

CustomBuildStep() {
  # assumes pwd has makefile$
  ChangeDir ../
  make clean
  make O=${PACKAGE_NAME}-build D=0 V=0 OPTIM=-O3
  ChangeDir ${PACKAGE_NAME}-build
}

CustomInstallStep() {
  # copy file to nacl toolchain lib directory
  readonly DEST_DIR="${NACL_SDK_BASE}/x86_64-nacl/lib${NACL_PACKAGES_BITSIZE}"
  readonly FILE="${NACL_PACKAGES_REPOSITORY}/${PACKAGE_NAME}/${PACKAGE_NAME}-build/libroxml.a"
  if [ -f "${FILE}" ]; then
    cp "${FILE}" "${DEST_DIR}"
  fi
}

CustomPackageInstall() {
  DefaultPreInstallStep
  DefaultDownloadStep
  DefaultExtractStep
  DefaultPatchStep
  CustomConfigureStep
  CustomBuildStep
  CustomInstallStep
  DefaultCleanUpStep
}

CustomPackageInstall
exit 0
