#ifndef DISCOVERYSERVER_H
#define DISCOVERYSERVER_H

#include <QObject>
#include <QUdpSocket>

class DiscoveryServer : public QObject
{
    Q_OBJECT
public:
    explicit DiscoveryServer(quint16 mirrorPort, QObject *parent = nullptr);

private slots:
    void processPendingDatagrams();

private:
    QUdpSocket *udpSocket;
    quint16 mirrorPort;
};

#endif
