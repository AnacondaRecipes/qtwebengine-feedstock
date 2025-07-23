#!/bin/sh

set -ex

if [[ "${target_platform}" == linux-* ]]; then
  CMAKE_ARGS="
    ${CMAKE_ARGS}
    -DQT_FEATURE_webengine_ozone_x11=ON
    -DQT_FEATURE_webengine_system_alsa=ON
    -DQT_FEATURE_webengine_system_minizip=ON
  "

  if [[ "${target_platform}" == linux-aarch64 ]]; then
    # Somehow a path for /usr/include/freetype2 is still making it into the CMake PkgConfig::FREETYPE IMPORT target.
    #
    # Webenginedriver is just used for tests and does not link against zlib correctly on linux-aarch64.
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

  # Extract and use newer Linux kernel headers as a workaround to updating the linux-sysroot-feedstock.
  cp -r kernel_headers/* ${BUILD_PREFIX}/${HOST}/sysroot/usr/

  # Hack to help the gn build tool find xorg headers during build. LD_LIBRARY_PATH is used rather than
  # LIBRARY_PATH because the `v8_context_snapshot_generator` tool needs to run during the build and requires libs
  # from our xorg packages.
  export LD_LIBRARY_PATH="${PREFIX}/lib:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64:${LD_LIBRARY_PATH}"
  export PKG_CONFIG_PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/pkgconfig:${BUILD_PREFIX}/${HOST}/sysroot/usr/share/pkgconfig:${PKG_CONFIG_PATH}"

  # IMPORTANT: Chromium didn't add flags to unvendor protobuf until very recently and not even the latest Qt 6.9.1
  # release has them included yet. We can't fix it until we upgrade Qt versions to maybe 6.10. That is the reason why
  # we're moving these headers around and that we should be able to stop as soon as Chromium provides a build option
  # to use_system_protobuf=1.

  # Copy required headers from conda packages to sysroot for Chromium/ANGLE build
  # We can't add ${PREFIX}/include to the include paths because bundled protobuf headers 
  # will conflict with the conda protobuf headers, so we copy specific headers to sysroot
  echo "Copying headers to sysroot for Chromium build..."
  
  # List of header directories to copy from ${PREFIX}/include to sysroot
  # These correspond to the X11/XCB/GL/EGL/ALSA/CUPS packages in host dependencies
  # KHR headers come from mesalib
  HEADER_DIRS=("xcb" "X11" "GL" "EGL" "alsa" "cups" "KHR")
  
  for header_dir in "${HEADER_DIRS[@]}"; do
    if [[ -d "${PREFIX}/include/${header_dir}" ]]; then
      cp -r "${PREFIX}/include/${header_dir}" "${BUILD_PREFIX}/${HOST}/sysroot/usr/include/"
      echo "  ✓ Copied ${header_dir} headers to sysroot"
    else
      echo "  ⚠ Warning: ${header_dir} headers not found in ${PREFIX}/include/${header_dir}"
    fi
  done
  
  echo "  ✓ Header copying complete - X11, XCB, GL, EGL, alsa, cups, and KHR headers available for Chromium build"
else
  CMAKE_ARGS="
    ${CMAKE_ARGS}
    -DQT_FEATURE_webengine_system_freetype=ON
    -DQT_FEATURE_webengine_system_gbm=OFF
    -DQT_FEATURE_webengine_system_minizip=OFF
  "
fi

# QT_FEATURE_webengine_system_icu has to be OFF or else icudtl.dat doesn't get installed
# https://github.com/qt/qtwebengine/blob/6.7.2/src/core/api/CMakeLists.txt#L171
cmake -S"${SRC_DIR}/${PKG_NAME}" -Bbuild -GNinja ${CMAKE_ARGS} \
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
  -DQT_FEATURE_webengine_system_glib=OFF \
  -DQT_FEATURE_webengine_system_harfbuzz=OFF \
  -DQT_FEATURE_webengine_system_icu=OFF \
  -DQT_FEATURE_webengine_system_libevent=OFF \
  -DQT_FEATURE_webengine_system_libjpeg=OFF \
  -DQT_FEATURE_webengine_system_libpci=OFF \
  -DQT_FEATURE_webengine_system_libpng=OFF \
  -DQT_FEATURE_webengine_system_libtiff=ON \
  -DQT_FEATURE_webengine_system_libwebp=OFF \
  -DQT_FEATURE_webengine_system_libxml=OFF \
  -DQT_FEATURE_webengine_system_libxslt=OFF \
  -DQT_FEATURE_webengine_system_opus=OFF \
  -DQT_FEATURE_webengine_system_poppler=ON \
  -DQT_FEATURE_webengine_system_snappy=OFF \
  -DQT_FEATURE_webengine_system_zlib=OFF
# TODO: Turn on zlib so that minizip is unvendored.

cmake --build build --target install -j${CPU_COUNT}

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
