@REM https://bugreports.qt.io/browse/QTBUG-107009
set "PATH=%SRC_DIR%\build\lib\qt6\bin;%PATH%"

REM Copy transport_security_state_static.h to solve the problem with generating it from archive.
if exist "pregenerated_files\transport_security_state_static.h" (
    mkdir -p %SRC_DIR%\build\src\core\Release\AMD64\gen\net\http\
    copy "pregenerated_files\transport_security_state_static.h" "%SRC_DIR%\build\src\core\Release\AMD64\gen\net\http\"
)

:: QT_FEATURE_webengine_system_icu has to be OFF or else icudtl.dat doesn't get installed
:: https://github.com/qt/qtwebengine/blob/6.7.2/src/core/api/CMakeLists.txt#L171
cmake -S"%SRC_DIR%/%PKG_NAME%" -B"%SRC_DIR%\build" -GNinja ^
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
    -DINSTALL_DATADIR=share/qt6 ^
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
    -DQT_FEATURE_webengine_system_freetype=OFF ^
    -DQT_FEATURE_webengine_system_gbm=OFF ^
    -DQT_FEATURE_webengine_system_glib=OFF ^
    -DQT_FEATURE_webengine_system_harfbuzz=OFF ^
    -DQT_FEATURE_webengine_system_icu=OFF ^
    -DQT_FEATURE_webengine_system_libevent=OFF ^
    -DQT_FEATURE_webengine_system_libjpeg=OFF ^
    -DQT_FEATURE_webengine_system_libpci=OFF ^
    -DQT_FEATURE_webengine_system_libpng=OFF ^
    -DQT_FEATURE_webengine_system_libtiff=ON ^
    -DQT_FEATURE_webengine_system_libwebp=ON ^
    -DQT_FEATURE_webengine_system_libxml=ON ^
    -DQT_FEATURE_webengine_system_libxslt=ON ^
    -DQT_FEATURE_webengine_system_minizip=ON ^
    -DQT_FEATURE_webengine_system_opus=OFF ^
    -DQT_FEATURE_webengine_system_poppler=ON ^
    -DQT_FEATURE_webengine_system_snappy=OFF ^
    -DQT_FEATURE_webengine_system_zlib=OFF
if errorlevel 1 exit 1

cmake --build build --target install -j %CPU_COUNT%
if errorlevel 1 exit 1

xcopy /y /s %LIBRARY_PREFIX%\lib\qt6\bin\*.dll %LIBRARY_PREFIX%\bin
if errorlevel 1 exit 1
