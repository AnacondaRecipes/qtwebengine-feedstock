TEMPLATE = app
QT += webenginequick
SOURCES += main-qtwebengine.cpp
RESOURCES += qml.qrc
CONFIG+=sdk_no_version_check

unix {
    LIBS += -L$$(PREFIX)/lib
}
mac {
    QT_MAC_SDK_NO_VERSION_CHECK=1
    QMAKE_MACOSX_DEPLOYMENT_TARGET=$$(c_stdlib_version)
    QMAKE_MAC_SDK=macosx$$(OSX_SDK_VER)
}
