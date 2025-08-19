@REM https://bugreports.qt.io/browse/QTBUG-107009
set "PATH=%SRC_DIR%\build\lib\qt6\bin;%PATH%"

:: QT_FEATURE_webengine_system_icu has to be OFF or else icudtl.dat doesn't get installed
:: https://github.com/qt/qtwebengine/blob/6.9.1/src/core/api/CMakeLists.txt#L186
::
:: Need at least ffmpeg v7.0 to unvendor on Windows.
:: Need at least libpng v1.6.43 to unvendor on Windows.
:: Need at least zlib v1.3.0 to unvendor on Windows.
cmake --log-level STATUS -S"%SRC_DIR%/%PKG_NAME%" -B"%SRC_DIR%\build" -GNinja ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DINSTALL_BINDIR=lib/qt6/bin ^
    -DINSTALL_PUBLICBINDIR=bin ^
    -DINSTALL_LIBEXECDIR=lib/qt6 ^
    -DINSTALL_DOCDIR=share/doc/qt6 ^
    -DINSTALL_ARCHDATADIR=lib/qt6 ^
    -DINSTALL_DATADIR=share/qt6 ^
    -DINSTALL_INCLUDEDIR=include/qt6 ^
    -DINSTALL_MKSPECSDIR=lib/qt6/mkspecs ^
    -DINSTALL_EXAMPLESDIR=share/doc/qt6/examples ^
    -DQT_FEATURE_qtpdf_build=ON ^
    -DQT_FEATURE_qtpdf_quick_build=ON ^
    -DQT_FEATURE_qtpdf_widgets_build=ON ^
    -DQT_FEATURE_qtwebengine_build=ON ^
    -DQT_FEATURE_qtwebengine_core_build=ON ^
    -DQT_FEATURE_qtwebengine_quick_build=ON ^
    -DQT_FEATURE_qtwebengine_widgets_build=ON ^
    -DQT_FEATURE_webengine_jumbo_build=OFF ^
    -DQT_FEATURE_webengine_pepper_plugins=ON ^
    -DQT_FEATURE_webengine_printing_and_pdf=ON ^
    -DQT_FEATURE_webengine_qt_freetype=OFF ^
    -DQT_FEATURE_webengine_qt_libjpeg=OFF ^
    -DQT_FEATURE_webengine_qt_libpng=OFF ^
    -DQT_FEATURE_webengine_qt_zlib=OFF ^
    -DQT_FEATURE_webengine_system_alsa=ON ^
    -DQT_FEATURE_webengine_system_ffmpeg=OFF ^
    -DQT_FEATURE_webengine_system_freetype=ON ^
    -DQT_FEATURE_webengine_system_gbm=ON ^
    -DQT_FEATURE_webengine_system_glib=ON ^
    -DQT_FEATURE_webengine_system_harfbuzz=ON ^
    -DQT_FEATURE_webengine_system_icu=OFF ^
    -DQT_FEATURE_webengine_system_libevent=ON ^
    -DQT_FEATURE_webengine_system_libjpeg=ON ^
    -DQT_FEATURE_webengine_system_libopenjpeg2=ON ^
    -DQT_FEATURE_webengine_system_libpci=OFF ^
    -DQT_FEATURE_webengine_system_libpng=OFF ^
    -DQT_FEATURE_webengine_system_libtiff=ON ^
    -DQT_FEATURE_webengine_system_libvpx=OFF ^
    -DQT_FEATURE_webengine_system_libwebp=ON ^
    -DQT_FEATURE_webengine_system_libxml=ON ^
    -DQT_FEATURE_webengine_system_libxslt=ON ^
    -DQT_FEATURE_webengine_system_minizip=OFF ^
    -DQT_FEATURE_webengine_system_opus=OFF ^
    -DQT_FEATURE_webengine_system_re2=ON ^
    -DQT_FEATURE_webengine_system_snappy=ON ^
    -DQT_FEATURE_webengine_system_ssl=OFF ^
    -DQT_FEATURE_webengine_system_zlib=OFF
if errorlevel 1 exit 1

cmake --build build --target install --config Release -j %CPU_COUNT%
if errorlevel 1 exit 1

xcopy /y /s %LIBRARY_PREFIX%\lib\qt6\bin\Qt6Pdf*.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1

xcopy /y /s %LIBRARY_PREFIX%\lib\qt6\bin\Qt6WebEngine*.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1
