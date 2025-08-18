#!/bin/sh

set -ex

if [[ "${target_platform}" == linux-* ]]; then
  CMAKE_ARGS="
    ${CMAKE_ARGS}
    -DQT_FEATURE_webengine_ozone_x11=ON
    -DQT_FEATURE_webengine_system_alsa=ON
  "

  if [[ "${target_platform}" == linux-aarch64 ]]; then
    # Somehow a path for /usr/include/freetype2 is still making it into the CMake PkgConfig::FREETYPE IMPORT target.
    #
    # Webenginedriver is just used for tests and does not link against vendored zlib correctly.
    #
    # Chromium vendors minigbm, a discontinued Intel project, which uses compiler features not compatible with our
    # aarch64 gcc compiler.
    CMAKE_ARGS="
      ${CMAKE_ARGS}
      -DFREETYPE_FOUND=1
      -DFREETYPE_INCLUDE_DIRS=${PREFIX}/include/freetype2
      -DFREETYPE_LDFLAGS=${PREFIX}/usr/lib;-lfreetype
      -DFREETYPE_LIBRARY_DIRS=${PREFIX}/usr/lib
      -DQT_FEATURE_webengine_system_freetype=OFF
      -DQT_FEATURE_webengine_system_gbm=ON
      -DQT_FEATURE_webenginedriver=OFF
    "
  else
    CMAKE_ARGS="
      ${CMAKE_ARGS}
      -DQT_FEATURE_webengine_system_freetype=ON
      -DQT_FEATURE_webengine_system_gbm=OFF
    "
  fi

  # Hack to help the generator executables, such as `v8_context_snapshot_generator`, that get called during a build
  # find unvendored libraries in our host prefix.
  export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH}"
else
  # Webenginedriver is just used for tests and does not link against vendored zlib correctly.
  CMAKE_ARGS="
    ${CMAKE_ARGS}
    -DQT_FORCE_WARN_APPLE_SDK_AND_XCODE_CHECK=ON
    -DQT_APPLE_SDK_PATH=${CONDA_BUILD_SYSROOT}
    -DQT_MAC_SDK_VERSION=${OSX_SDK_VER}
    -DQT_FEATURE_webengine_system_freetype=ON
    -DQT_FEATURE_webengine_system_gbm=OFF
    -DQT_FEATURE_webenginedriver=OFF
  "
fi

# IMPORTANT: Chromium didn't add flags to unvendor protobuf until very recently and not even the latest Qt 6.9.1
# release has them included yet. We can't fix it until we upgrade Qt versions to maybe 6.10. That is the reason why
# we're removing these headers and we should be able to stop as soon as Chromium provides a build option to
# use_system_protobuf=1.
#
# We can't add ${PREFIX}/include to the include paths because our protobuf, unicode, openssl, and abseil packages are
# both lib and development packages and the included headers will get used instead of the vendored ones. To resolve
# this, we remove the conda ones to avoid conflicts but really these should be split into devel and lib packages so
# the unwanted headers are never even installed.
rm -rf ${PREFIX}/include/google/protobuf
rm -rf ${PREFIX}/include/unicode
rm -rf ${PREFIX}/include/openssl
rm -rf ${PREFIX}/include/absl
rm -rf ${PREFIX}/include/vulkan
rm -rf ${PREFIX}/include/zlib.h
rm -rf ${PREFIX}/include/jconfig.h
rm -rf ${PREFIX}/include/jerror.h
rm -rf ${PREFIX}/include/jmorecfg.h
rm -rf ${PREFIX}/include/jpeglib.h

# TODO: Try to unbundle nasm and absl as well.

# QT_FEATURE_webengine_system_icu has to be OFF or else icudtl.dat doesn't get installed
# https://github.com/qt/qtwebengine/blob/6.9.1/src/core/api/CMakeLists.txt#L186
#
# Need at least ffmpeg v7.0 to unvendor on Unix.
# Need at least libpng v1.6.43 to unvendor on Unix.
# Need at least zlib v1.3.0 to unvendor on Unix.
#
# Both minizip and zlib have to be ON to use system minizip.
cmake --log-level STATUS -S"${SRC_DIR}/${PKG_NAME}" -Bbuild -GNinja ${CMAKE_ARGS} \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DCMAKE_BUILD_WITH_INSTALL_RPATH=ON \
  -DCMAKE_FIND_FRAMEWORK=LAST \
  -DBUILD_WITH_PCH=OFF \
  -DINSTALL_BINDIR=lib/qt6/bin \
  -DINSTALL_PUBLICBINDIR=bin \
  -DINSTALL_LIBEXECDIR=lib/qt6 \
  -DINSTALL_DOCDIR=share/doc/qt6 \
  -DINSTALL_ARCHDATADIR=lib/qt6 \
  -DINSTALL_DATADIR=share/qt6 \
  -DINSTALL_INCLUDEDIR=include/qt6 \
  -DINSTALL_MKSPECSDIR=lib/qt6/mkspecs \
  -DINSTALL_EXAMPLESDIR=share/doc/qt6/examples \
  -DQT_FEATURE_qtpdf_build=ON \
  -DQT_FEATURE_qtpdf_quick_build=ON \
  -DQT_FEATURE_qtpdf_widgets_build=ON \
  -DQT_FEATURE_qtwebengine_build=ON \
  -DQT_FEATURE_qtwebengine_core_build=ON \
  -DQT_FEATURE_qtwebengine_quick_build=ON \
  -DQT_FEATURE_qtwebengine_widgets_build=ON \
  -DQT_FEATURE_webengine_jumbo_build=OFF \
  -DQT_FEATURE_webengine_pepper_plugins=ON \
  -DQT_FEATURE_webengine_printing_and_pdf=ON \
  -DQT_FEATURE_webengine_qt_freetype=OFF \
  -DQT_FEATURE_webengine_qt_libjpeg=OFF \
  -DQT_FEATURE_webengine_qt_libpng=OFF \
  -DQT_FEATURE_webengine_qt_zlib=OFF \
  -DQT_FEATURE_webengine_system_ffmpeg=OFF \
  -DQT_FEATURE_webengine_system_glib=ON \
  -DQT_FEATURE_webengine_system_harfbuzz=ON \
  -DQT_FEATURE_webengine_system_icu=OFF \
  -DQT_FEATURE_webengine_system_libevent=ON \
  -DQT_FEATURE_webengine_system_libjpeg=OFF \
  -DQT_FEATURE_webengine_system_libopenjpeg2=ON \
  -DQT_FEATURE_webengine_system_libpci=OFF \
  -DQT_FEATURE_webengine_system_libpng=OFF \
  -DQT_FEATURE_webengine_system_libtiff=ON \
  -DQT_FEATURE_webengine_system_libvpx=ON \
  -DQT_FEATURE_webengine_system_libwebp=ON \
  -DQT_FEATURE_webengine_system_libxml=ON \
  -DQT_FEATURE_webengine_system_libxslt=ON \
  -DQT_FEATURE_webengine_system_minizip=OFF \
  -DQT_FEATURE_webengine_system_opus=ON \
  -DQT_FEATURE_webengine_system_snappy=OFF \
  -DQT_FEATURE_webengine_system_ssl=OFF \
  -DQT_FEATURE_webengine_system_zlib=OFF

cmake --build build --target install --config Release -j${CPU_COUNT}

pushd "${PREFIX}"

mkdir -p bin

if [[ -f "${SRC_DIR}"/build/user_facing_tool_links.txt ]]; then
  for links in "${SRC_DIR}"/build/user_facing_tool_links.txt; do
    while read _line; do
      if [[ -n "${_line}" ]]; then
        ln -sf ${_line}
      fi
    done < ${links}
  done
fi
