TEMPLATE = app
TARGET = SimpleDemo

# --- [FIX] ADD 'quickcontrols2' HERE ---
# You already added webview, widgets, svg, network - Perfect!
QT += core gui qml quick quickcontrols2 bluetooth androidextras webview widgets svg network

CONFIG += c++11

SOURCES += main.cpp \
    WifiManager.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Android Specific Setup
ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/res/values/libs.xml

HEADERS += \
    WifiManager.h

# --- CRITICAL ADDITION BELOW ---
# This line prevents the "Ministro" popup by forcing a single-architecture build
ANDROID_ABIS = armeabi-v7a
