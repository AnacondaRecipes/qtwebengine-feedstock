#!/bin/sh

set -ex

if [[ "${target_platform}" == linux-* ]]; then
  rm -rf qtwebengine/src/3rdparty
  cp -r 3rdparty qtwebengine/src/

  cp /usr/include/gbm.h ${BUILD_PREFIX}/include/
  cp /usr/include/gbm.h ${BUILD_PREFIX}/x86_64-conda-linux-gnu/sysroot/usr/include/
  cp /usr/include/gbm.h ${BUILD_PREFIX}/${HOST}/sysroot/usr/include/
  cp /usr/include/gbm.h ${PREFIX}/include/

  CMAKE_ARGS="
    ${CMAKE_ARGS}
    -DQT_FEATURE_webengine_ozone_x11=ON
    -DQT_FEATURE_webengine_system_alsa=ON
    -DALSA_FOUND=1
    -DALSA_INCLUDE_DIRS=${BUILD_PREFIX}/${HOST}/sysroot/usr/include/alsa
    -DALSA_LDFLAGS=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64;-lasound
    -DALSA_LIBRARY_DIRS=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64
    -DFREETYPE_FOUND=1
    -DFREETYPE_INCLUDE_DIRS=${BUILD_PREFIX}/${HOST}/sysroot/usr/include/freetype2
    -DFREETYPE_LDFLAGS=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64;-lfreetype
    -DFREETYPE_LIBRARY_DIRS=${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64
  "

  # hack to help the gn build tool find CDT pkgconfig and libraries during build.
  export LD_LIBRARY_PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64:${BUILD_PREFIX}/${HOST}/sysroot/usr/lib:${LD_LIBRARY_PATH}"
  export PKG_CONFIG_PATH="${BUILD_PREFIX}/${HOST}/sysroot/usr/lib64/pkgconfig:${BUILD_PREFIX}/${HOST}/sysroot/usr/share/pkgconfig:${PKG_CONFIG_PATH}"

  # hack to help the gn build tool find the xcb headers. we can't add ${PREFIX}/include
  # to the include paths because bundled headers will conflict with the host headers.
  cp -r "${PREFIX}/include/xcb" "${BUILD_PREFIX}/${HOST}/sysroot/usr/include/"
fi

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
  -DQT_FEATURE_webengine_gnome_keyring=OFF \
  -DQT_FEATURE_webengine_jumbo_build=OFF \
  -DQT_FEATURE_webengine_pepper_plugins=ON \
  -DQT_FEATURE_webengine_printing_and_pdf=ON \
  -DQT_FEATURE_webengine_qt_freetype=OFF \
  -DQT_FEATURE_webengine_qt_libjpeg=OFF \
  -DQT_FEATURE_webengine_qt_libpng=OFF \
  -DQT_FEATURE_webengine_qt_zlib=OFF \
  -DQT_FEATURE_webengine_system_ffmpeg=OFF \
  -DQT_FEATURE_webengine_system_freetype=OFF \
  -DQT_FEATURE_webengine_system_gbm=OFF \
  -DQT_FEATURE_webengine_system_glib=OFF \
  -DQT_FEATURE_webengine_system_harfbuzz=OFF \
  -DQT_FEATURE_webengine_system_icu=ON \
  -DQT_FEATURE_webengine_system_libdrm=OFF \
  -DQT_FEATURE_webengine_system_libevent=OFF \
  -DQT_FEATURE_webengine_system_libjpeg=OFF \
  -DQT_FEATURE_webengine_system_libpci=OFF \
  -DQT_FEATURE_webengine_system_libpng=OFF \
  -DQT_FEATURE_webengine_system_libtiff=ON \
  -DQT_FEATURE_webengine_system_libwebp=ON \
  -DQT_FEATURE_webengine_system_libxml=ON \
  -DQT_FEATURE_webengine_system_minigbm=ON \
  -DQT_FEATURE_webengine_system_minizip=ON \
  -DQT_FEATURE_webengine_system_opus=ON \
  -DQT_FEATURE_webengine_system_poppler=ON \
  -DQT_FEATURE_webengine_system_snappy=OFF \
  -DQT_FEATURE_webengine_system_zlib=OFF

cmake --build build --target install

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
