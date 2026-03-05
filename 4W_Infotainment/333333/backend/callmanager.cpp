/*#include "callmanager.h"
#include <QDebug>
#include <QProcess>

CallManager::CallManager(QObject *parent)
    : QObject(parent)
{
    qDebug() << "CallManager constructed";
}

void CallManager::makeCall(const QString &number)
{
    qDebug() << "========== MAKECALL CALLED ==========";
    qDebug() << "Number to call:" << number;

#ifdef Q_OS_ANDROID
    qDebug() << "Android detected - Using ecall helper script";

    QString scriptPath = "/data/local/tmp/ecall_dial.sh";
    QString command = scriptPath + " " + number;

    QProcess process;
    //process.start("su", QStringList() << "-c" << command);
    process.start(scriptPath, QStringList() << number);

    if (process.waitForFinished(8000)) {
        int exitCode = process.exitCode();
        QByteArray output = process.readAll();
        QByteArray error = process.readAllStandardError();

        qDebug() << "Exit code:" << exitCode;
        qDebug() << "Output:" << output;
        qDebug() << "Error:" << error;

        if (exitCode == 0) {
            qDebug() << "✅ Call initiated successfully";
            emit callInitiated(number);
        } else {
            qDebug() << "❌ Call initiation failed";
            emit callFailed(number, "Script execution failed");
        }
    } else {
        qDebug() << "❌ Process timed out";
        process.kill();
        emit callFailed(number, "Timeout");
    }
#endif
}*/

#include "callmanager.h"
#include <QDebug>
#include <QProcess>
#include <QGeoCoordinate>
#include <QGeoPositionInfoSource>
#include <QCoreApplication>
#include <QTimer>

CallManager::CallManager(QObject *parent)
    : QObject(parent)
    , m_locationSource(nullptr)
{
    qDebug() << "CallManager constructed";

    // Set default vehicle ID (you can change this)
    m_vehicleId = "OKT507C-001";

    // Initialize location services
    m_locationSource = QGeoPositionInfoSource::createDefaultSource(this);
    if (m_locationSource) {
        m_locationSource->setUpdateInterval(10000); // Update every 10 seconds
        connect(m_locationSource, &QGeoPositionInfoSource::positionUpdated,
                this, &CallManager::onPositionUpdated);

        // Fix for Qt 5.15.2 - use error signal
        connect(m_locationSource, SIGNAL(error(QGeoPositionInfoSource::Error)),
                this, SLOT(onLocationError(QGeoPositionInfoSource::Error)));
    } else {
        qDebug() << "❌ Location source not available!";
    }
}

void CallManager::startLocationUpdates()
{
    if (m_locationSource) {
        m_locationSource->startUpdates();
        qDebug() << "📍 Location updates started";
    }
}

void CallManager::stopLocationUpdates()
{
    if (m_locationSource) {
        m_locationSource->stopUpdates();
        qDebug() << "📍 Location updates stopped";
    }
}

void CallManager::onPositionUpdated(const QGeoPositionInfo &info)
{
    if (info.isValid()) {
        QGeoCoordinate coord = info.coordinate();
        m_currentLocation = QString("%1,%2")
                                .arg(coord.latitude(), 0, 'f', 6)
                                .arg(coord.longitude(), 0, 'f', 6);

        qDebug() << "📍 Location updated:" << m_currentLocation;
        emit locationUpdated(m_currentLocation);
    }
}

void CallManager::onLocationError(QGeoPositionInfoSource::Error error)
{
    QString errorMsg;
    switch(error) {
    case QGeoPositionInfoSource::AccessError:
        errorMsg = "Access Error";
        break;
    case QGeoPositionInfoSource::ClosedError:
        errorMsg = "Closed Error";
        break;
    case QGeoPositionInfoSource::NoError:
        errorMsg = "No Error";
        break;
    case QGeoPositionInfoSource::UnknownSourceError:
    default:
        errorMsg = "Unknown Error";
        break;
    }
    qDebug() << "❌ Location error:" << errorMsg;
}

bool CallManager::executeScript(const QString &scriptPath, const QStringList &args)
{
    QProcess process;
    process.start(scriptPath, args);

    if (process.waitForFinished(15000)) {  // 15 seconds timeout
        int exitCode = process.exitCode();
        QByteArray output = process.readAll();
        QByteArray error = process.readAllStandardError();

        qDebug() << "Script exit code:" << exitCode;
        if (!output.isEmpty())
            qDebug() << "Output:" << output;
        if (!error.isEmpty())
            qDebug() << "Error:" << error;

        return (exitCode == 0);
    } else {
        qDebug() << "❌ Script execution timed out";
        process.kill();
        return false;
    }
}

void CallManager::makeCall(const QString &number)
{
    qDebug() << "========== MAKECALL CALLED ==========";
    qDebug() << "Number to call:" << number;

#ifdef Q_OS_ANDROID
    QString scriptPath = "/data/local/tmp/ecall_dial.sh";

    // For call only, pass just the number with empty location
    QStringList args;
    args << number << "" << "";

    if (executeScript(scriptPath, args)) {
        qDebug() << "✅ Call initiated successfully";
        emit callInitiated(number);
    } else {
        qDebug() << "❌ Call initiation failed";
        emit callFailed(number, "Script execution failed");
    }
#endif
}

// ADD THIS MISSING IMPLEMENTATION
void CallManager::makeEmergencyCall(const QString &number)
{
    qDebug() << "========== EMERGENCY CALL CALLED ==========";
    qDebug() << "Number to call:" << number;

    // Just call the regular makeCall for now
    // Or you can add special emergency logic here
    makeCall(number);
}

void CallManager::sendEmergencySMS(const QString &number, const QString &message)
{
    qDebug() << "========== SEND EMERGENCY SMS ==========";
    qDebug() << "To:" << number;
    qDebug() << "Message:" << message;

#ifdef Q_OS_ANDROID
    QString scriptPath = "/data/local/tmp/send_sms.sh";
    QStringList args;
    args << number << message;

    bool success = executeScript(scriptPath, args);
    emit smsSent(number, success);
#endif
}

void CallManager::triggerEmergency(const QString &number)
{
    qDebug() << "========== 🚨 EMERGENCY TRIGGERED ==========";
    qDebug() << "Emergency number:" << number;

    // Start location updates if not already running
    startLocationUpdates();

    // Wait a moment for location (if GPS is slow, use last known)
    QTimer::singleShot(2000, [this, number]() {
        QString location = m_currentLocation;

        // If no GPS yet, use placeholder
        if (location.isEmpty()) {
            location = "12.9716,77.5946"; // Default to Bangalore coordinates
            qDebug() << "⚠️ Using default location (GPS not available)";
        }

#ifdef Q_OS_ANDROID
        QString scriptPath = "/data/local/tmp/ecall_dial.sh";
        QStringList args;
        args << number << location << m_vehicleId;

        qDebug() << "📍 Sending location:" << location;
        qDebug() << "🚗 Vehicle ID:" << m_vehicleId;

        if (executeScript(scriptPath, args)) {
            qDebug() << "✅ Emergency sequence completed successfully";
            emit emergencyTriggered(number, location);
        } else {
            qDebug() << "❌ Emergency sequence failed";
            emit callFailed(number, "Emergency script failed");
        }
#endif
    });
}

void CallManager::setVehicleId(const QString &id)
{
    if (m_vehicleId != id) {
        m_vehicleId = id;
        emit vehicleIdChanged(id);
        qDebug() << "🚗 Vehicle ID set to:" << id;
    }
}
