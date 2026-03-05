/*#ifndef CALLMANAGER_H
#define CALLMANAGER_H

#include <QObject>

class CallManager : public QObject
{
    Q_OBJECT
public:
    explicit CallManager(QObject *parent = nullptr);

    Q_INVOKABLE void makeCall(const QString &number);

signals:
    void callInitiated(const QString &number);
    void callFailed(const QString &number, const QString &reason);
};

#endif // CALLMANAGER_H
*/

#ifndef CALLMANAGER_H
#define CALLMANAGER_H

#include <QObject>
#include <QGeoPositionInfo>
#include <QGeoPositionInfoSource>

class CallManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentLocation READ currentLocation NOTIFY locationUpdated)
    Q_PROPERTY(QString vehicleId READ vehicleId WRITE setVehicleId NOTIFY vehicleIdChanged)

public:
    explicit CallManager(QObject *parent = nullptr);

    Q_INVOKABLE void makeCall(const QString &number);
    Q_INVOKABLE void makeEmergencyCall(const QString &number);  // Keep this
    Q_INVOKABLE void sendEmergencySMS(const QString &number, const QString &message);
    Q_INVOKABLE void triggerEmergency(const QString &number);

    // Location methods
    Q_INVOKABLE void startLocationUpdates();
    Q_INVOKABLE void stopLocationUpdates();
    QString currentLocation() const { return m_currentLocation; }

    // Vehicle ID
    QString vehicleId() const { return m_vehicleId; }
    void setVehicleId(const QString &id);

signals:
    void callInitiated(const QString &number);
    void callFailed(const QString &number, const QString &reason);
    void smsSent(const QString &number, bool success);
    void emergencyTriggered(const QString &number, const QString &location);
    void locationUpdated(const QString &location);
    void vehicleIdChanged(const QString &vehicleId);

private slots:
    void onPositionUpdated(const QGeoPositionInfo &info);
    void onLocationError(QGeoPositionInfoSource::Error error);

private:
    QString m_currentLocation;
    QString m_vehicleId;
    QGeoPositionInfoSource *m_locationSource;
    bool executeScript(const QString &scriptPath, const QStringList &args);
};

#endif // CALLMANAGER_H
