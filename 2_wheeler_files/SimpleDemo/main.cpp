#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QtQml>  // <--- IMPORTANT: Needed to register C++ types
#include <QtWebView/QtWebView> // <--- NEW: Added for Maps
#include "WifiManager.h" // <--- Your Header File

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    // --- NEW: This line prevents the Map from being a black screen ---
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);

    QGuiApplication app(argc, argv);

    // --- NEW: Initialize the Web Engine for the Map ---
    QtWebView::initialize();

    // ====================================================================
    // 1. REGISTER THE WIFI MANAGER
    // This tells QML: "Hey, there is a C++ class called WifiManager!"
    // ====================================================================
    qmlRegisterType<WifiManager>("com.votary.wifi", 1, 0, "WifiManager");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}


