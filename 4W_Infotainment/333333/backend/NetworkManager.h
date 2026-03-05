#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QNetworkInterface>
#include <QHostAddress>
#include <QTimer>
#include <QString>

class NetworkManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString ipAddress READ ipAddress NOTIFY ipAddressChanged)
    Q_PROPERTY(QString networkType READ networkType NOTIFY networkTypeChanged)
    Q_PROPERTY(QString networkName READ networkName NOTIFY networkNameChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY connectionChanged)

public:
    explicit NetworkManager(QObject *parent = nullptr);

    QString ipAddress() const { return m_ipAddress; }
    QString networkType() const { return m_networkType; }
    QString networkName() const { return m_networkName; }
    bool isConnected() const { return m_isConnected; }

    Q_INVOKABLE void refreshNetworkInfo();
    Q_INVOKABLE QString copyToClipboard(const QString &text);

signals:
    void ipAddressChanged();
    void networkTypeChanged();
    void networkNameChanged();
    void connectionChanged();

private slots:
    void updateNetworkInfo();

private:
    QString m_ipAddress;
    QString m_networkType;
    QString m_networkName;
    bool m_isConnected;
    QTimer *m_updateTimer;

    void detectNetworkInfo();
    QString getInterfaceType(const QNetworkInterface &interface);
};

#endif // NETWORKMANAGER_H
