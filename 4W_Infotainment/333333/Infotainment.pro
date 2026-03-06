QT += network core gui serialport
QT += quick gui multimedia positioning svg sensors

# newly added line
QT += androidextras

android {
    QT += androidextras webview
    # ------------- newly added lines --------------
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    ANDROID_BUILD_TOOLS_VERSION = 36.0.0
    ANDROID_TARGET_SDK_VERSION = 36
    contains(ANDROID_TARGET_ARCH,armeabi-v7a) {
        ANDROID_EXTRA_LIBS =
    }
    #-----------------------------------------------
    #ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    #ANDROID_MIN_SDK_VERSION = 21
    #ANDROID_TARGET_SDK_VERSION = 33
}

CONFIG += c++11
CONFIG += qtquickcompiler

#--------- newly added lines ---------
CONFIG += c++11 debug                #
DEFINES += QT_MESSAGELOGCONTEXT      #
#-------------------------------------

TEMPLATE = app
TARGET = CarInfotainment
VERSION = 1.0.0

SOURCES += \
    backend/DiscoveryServer.cpp \
    backend/NetworkManager.cpp \
    backend/callmanager.cpp \
    main.cpp \
    backend/mirrorimageprovider.cpp\
    backend/mirrorManager.cpp\
    backend/MirrorServer.cpp\
    backend/Tcpworker.cpp\

HEADERS += \
    backend/DiscoveryServer.h \
    backend/NetworkManager.h \
    backend/callmanager.h \
    backend/mirrorimageprovider.h\
    backend/mirrorManager.h\
    backend/MirrorServer.h\
    backend/TcpWorker.h\

RESOURCES += resources.qrc

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/res/values/libs.xml \
    android/gradle/wrapper/gradle-wrapper.jar
