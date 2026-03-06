/*#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QUrl>
#include <QDebug>
#include <QtGlobal>
#include <QSurfaceFormat>
#include <QtQml>
#include <QQmlContext>

#include "backend/mirrorManager.h"  // Added for mirroring
#include "backend/NetworkManager.h" // new added

// Platform-specific web initialization
#ifdef Q_OS_ANDROID
#include <QtWebView/QtWebView>
#else
#include <QtWebEngine/QtWebEngine>
#endif

int main(int argc, char *argv[])
{
    // ---------- Platform Setup (BEFORE QGuiApplication) ----------
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    // Android: Use OpenGL ES + WebView
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
    QtWebView::initialize();  // CRITICAL: Must be before QGuiApplication
#else
    // Desktop: Share GL contexts + WebEngine
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    // QtWebEngine::initialize();  // Commented out to avoid conflict
#endif

    // ---------- Application ----------
    QGuiApplication app(argc, argv);

    // Set application metadata
    app.setOrganizationName("Votary");
    app.setOrganizationDomain("votarytech.com");
    app.setApplicationName("Automotive Infotainment");

    // ---------- Create Backend Instances ----------
    MirrorManager mirrorManager;

    // Register NetworkManager as QML singleton (RECOMMENDED approach)
    qmlRegisterSingletonType<NetworkManager>("Votary.Network", 1, 0, "NetworkManager",
                                             [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
                                                 Q_UNUSED(engine)
                                                 Q_UNUSED(scriptEngine)
                                                 NetworkManager *networkManager = new NetworkManager();
                                                 return networkManager;
                                             });

    // Alternative: Register as regular type if you prefer multiple instances
    // qmlRegisterType<NetworkManager>("Votary.Network", 1, 0, "NetworkManager");

    // ---------- QML Engine ----------
    QQmlApplicationEngine engine;

    // Expose MirrorManager to QML as a context property
    engine.rootContext()->setContextProperty("MirrorManager", &mirrorManager);

    // Add image provider for mirroring
    engine.addImageProvider("mirror", mirrorManager.imageProvider());

    // Optional: Expose NetworkManager as context property too (for backward compatibility)
    NetworkManager *networkManagerInstance = new NetworkManager();
    engine.rootContext()->setContextProperty("NetworkManagerInstance", networkManagerInstance);

    // Optional: Expose application version and build info
    engine.rootContext()->setContextProperty("AppVersion", "1.0.0");
    engine.rootContext()->setContextProperty("BuildDate", QString(__DATE__));
    engine.rootContext()->setContextProperty("BuildTime", QString(__TIME__));

    // Load main QML file
    const QUrl url(QStringLiteral("qrc:/main.qml"));

    // Connection for QML loading errors
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl) {
                             qCritical() << "QML failed to load from URL:" << url;
                             QCoreApplication::exit(-1);
                         } else if (obj) {
                             qDebug() << "QML loaded successfully";

                             // Log platform info
                             qDebug() << "Platform:" << QGuiApplication::platformName();
                             qDebug() << "High DPI scaling:" <<
                                 (QCoreApplication::testAttribute(Qt::AA_EnableHighDpiScaling) ? "Enabled" : "Disabled");

#ifdef Q_OS_ANDROID
                             qDebug() << "Android: Using QtWebView";
#else
                             qDebug() << "Desktop: Using QtWebEngine (if enabled)";
#endif
                         }
                     }, Qt::QueuedConnection);

    // Handle engine warnings
    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
                     [](const QList<QQmlError> &warnings) {
                         for (const QQmlError &warning : warnings) {
                             qWarning() << "QML Warning:" << warning.toString();
                         }
                     });

    // Load the QML
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No QML root objects created";
        return -1;
    }

    qDebug() << "🚀 Application started successfully";

    // Start network monitoring (optional)
    if (networkManagerInstance) {
        networkManagerInstance->refreshNetworkInfo();
        qDebug() << "Network monitoring initialized";
    }

    return app.exec();
}*/

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>
#include <QDir>
#include <QResource>
#include <QFile>
#include <QCoreApplication>
#include <QUrl>
#include <QtGlobal>
#include <QSurfaceFormat>
#include <QtQml>

#include "backend/callmanager.h"
#include "backend/mirrorManager.h"
#include "backend/NetworkManager.h"

// Platform-specific web initialization
#ifdef Q_OS_ANDROID
#include <QtWebView/QtWebView>
#include <QtAndroid>
#include <QAndroidJniObject>
#else
#include <QtWebEngine/QtWebEngine>
#endif

int main(int argc, char *argv[])
{
    // ---------- Platform Setup (BEFORE QGuiApplication) ----------
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    // Android: Use OpenGL ES + WebView
    QCoreApplication::setAttribute(Qt::AA_UseOpenGLES);
    QtWebView::initialize();  // CRITICAL: Must be before QGuiApplication
#else
    // Desktop: Share GL contexts + WebEngine
    QCoreApplication::setAttribute(Qt::AA_ShareOpenGLContexts);
    // QtWebEngine::initialize();  // Commented out to avoid conflict
#endif

    // ---------- Application ----------
    QGuiApplication app(argc, argv);

    qDebug() << "========== EMERGENCY CALL APP STARTED ==========";
    qDebug() << "Current working directory:" << QDir::currentPath();

    // Set application metadata
    app.setOrganizationName("Votary");
    app.setOrganizationDomain("votarytech.com");
    app.setApplicationName("Automotive Infotainment");

#ifdef Q_OS_ANDROID
    qDebug() << "Platform: Android - checking permissions";

    // Check and request CALL_PHONE permission
    QtAndroid::requestPermissionsSync(QStringList() << "android.permission.CALL_PHONE");

    QtAndroid::PermissionResult r = QtAndroid::checkPermission("android.permission.CALL_PHONE");
    qDebug() << "Initial CALL_PHONE permission status:"
             << (r == QtAndroid::PermissionResult::Granted ? "GRANTED" : "DENIED");

    if (r != QtAndroid::PermissionResult::Granted) {
        qDebug() << "Requesting CALL_PHONE permission...";
        auto result = QtAndroid::requestPermissionsSync(QStringList() << "android.permission.CALL_PHONE");

        if (result.contains("android.permission.CALL_PHONE")) {
            QtAndroid::PermissionResult r2 = result.value("android.permission.CALL_PHONE");
            qDebug() << "Permission request result:"
                     << (r2 == QtAndroid::PermissionResult::Granted ? "GRANTED" : "DENIED");
        }
    }
#else
    qDebug() << "Platform: Desktop";
#endif

    // List all available resources for debugging
    qDebug() << "Available resources in :/ :";
    QStringList resources = QDir(":").entryList();
    foreach (const QString &path, resources) {
        qDebug() << "  :/" << path;
    }

    // Check if main.qml exists in resources
    bool mainQmlExists = QFile::exists(":/main.qml");
    qDebug() << "Resource :/main.qml exists:" << mainQmlExists;

    // If not found, check alternative paths
    if (!mainQmlExists) {
        qDebug() << "Checking alternative paths:";
        qDebug() << "  :/qml/main.qml exists:" << QFile::exists(":/qml/main.qml");
        qDebug() << "  :/resources/main.qml exists:" << QFile::exists(":/resources/main.qml");
        qDebug() << "  main.qml (local) exists:" << QFile::exists("main.qml");
    }

    // ---------- Create Backend Instances ----------
    qDebug() << "Creating CallManager...";
    CallManager callManager;

    MirrorManager mirrorManager;

    // Register NetworkManager as QML singleton (RECOMMENDED approach)
    qmlRegisterSingletonType<NetworkManager>("Votary.Network", 1, 0, "NetworkManager",
                                             [](QQmlEngine *engine, QJSEngine *scriptEngine) -> QObject* {
                                                 Q_UNUSED(engine)
                                                 Q_UNUSED(scriptEngine)
                                                 NetworkManager *networkManager = new NetworkManager();
                                                 return networkManager;
                                             });

    // Alternative: Register as regular type if you prefer multiple instances
    // qmlRegisterType<NetworkManager>("Votary.Network", 1, 0, "NetworkManager");

    // ---------- QML Engine ----------
    QQmlApplicationEngine engine;

    qDebug() << "Setting context properties...";

    // Set context properties for all managers
    engine.rootContext()->setContextProperty("CallManager", &callManager);
    engine.rootContext()->setContextProperty("MirrorManager", &mirrorManager);

    // Add image provider for mirroring
    engine.addImageProvider("mirror", mirrorManager.imageProvider());

    // Create and expose NetworkManager instance (for backward compatibility)
    NetworkManager *networkManagerInstance = new NetworkManager();
    engine.rootContext()->setContextProperty("NetworkManagerInstance", networkManagerInstance);

    // Optional: Expose application version and build info
    engine.rootContext()->setContextProperty("AppVersion", "1.0.0");
    engine.rootContext()->setContextProperty("BuildDate", QString(__DATE__));
    engine.rootContext()->setContextProperty("BuildTime", QString(__TIME__));

    // Try multiple possible paths for QML
    QStringList possiblePaths;
    possiblePaths << "qrc:/main.qml"
                  << "qrc:///main.qml"
                  << "qrc:/qml/main.qml"
                  << "qrc:///qml/main.qml"
                  << "main.qml";

    // Connection for QML loading errors
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [possiblePaths](QObject *obj, const QUrl &objUrl) {
                         if (!obj && possiblePaths.contains(objUrl.toString())) {
                             qCritical() << "QML failed to load from URL:" << objUrl.toString();
                             QCoreApplication::exit(-1);
                         } else if (obj) {
                             qDebug() << "QML loaded successfully";

                             // Log platform info
                             qDebug() << "Platform:" << QGuiApplication::platformName();
                             qDebug() << "High DPI scaling:" <<
                                 (QCoreApplication::testAttribute(Qt::AA_EnableHighDpiScaling) ? "Enabled" : "Disabled");

#ifdef Q_OS_ANDROID
                             qDebug() << "Android: Using QtWebView";
#else
                             qDebug() << "Desktop: Using QtWebEngine (if enabled)";
#endif
                         }
                     }, Qt::QueuedConnection);

    // Handle engine warnings
    QObject::connect(&engine, &QQmlApplicationEngine::warnings,
                     [](const QList<QQmlError> &warnings) {
                         for (const QQmlError &warning : warnings) {
                             qWarning() << "QML Warning:" << warning.toString();
                         }
                     });

    // Try to load QML from multiple possible paths
    bool loaded = false;
    for (const QString &path : possiblePaths) {
        qDebug() << "Attempting to load:" << path;
        engine.load(QUrl(path));

        if (!engine.rootObjects().isEmpty()) {
            qDebug() << "SUCCESS! Loaded from:" << path;
            loaded = true;
            break;
        }
    }

    if (!loaded) {
        qDebug() << "ERROR: Failed to load QML from any path!";
        qDebug() << "Please check that main.qml is in the resources.";
        return -1;
    }

    if (engine.rootObjects().isEmpty()) {
        qCritical() << "No QML root objects created";
        return -1;
    }

    qDebug() << "========== APP RUNNING SUCCESSFULLY ==========";
    qDebug() << "🚀 Application started successfully";

    // Start network monitoring (optional)
    if (networkManagerInstance) {
        networkManagerInstance->refreshNetworkInfo();
        qDebug() << "Network monitoring initialized";
    }

    return app.exec();
}
