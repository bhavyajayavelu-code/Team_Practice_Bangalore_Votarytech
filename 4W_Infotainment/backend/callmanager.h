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
#include <QProcess>

class CallManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString vehicleId READ vehicleId WRITE setVehicleId NOTIFY vehicleIdChanged)

public:
    explicit CallManager(QObject *parent = nullptr);

    Q_INVOKABLE void makeCall(const QString &number);
    Q_INVOKABLE void makeEmergencyCall(const QString &number);
    Q_INVOKABLE void sendEmergencySMS(const QString &number, const QString &message);
    Q_INVOKABLE void triggerEmergency(const QString &number);

    // Vehicle ID
    QString vehicleId() const { return m_vehicleId; }
    void setVehicleId(const QString &id);

signals:
    void callInitiated(const QString &number);
    void callFailed(const QString &number, const QString &reason);
    void smsSent(const QString &number, bool success);
    void emergencyTriggered(const QString &number, const QString &location);
    void vehicleIdChanged(const QString &vehicleId);

private:
    QString m_vehicleId;
    bool executeScript(const QString &scriptPath, const QStringList &args);
};

#endif // CALLMANAGER_H
