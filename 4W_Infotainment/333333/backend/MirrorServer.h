#ifndef MIRRORSERVER_H
#define MIRRORSERVER_H

#include <QTcpServer>
#include <QObject>

class MirrorServer : public QObject {
    Q_OBJECT
public:
    explicit MirrorServer(QObject *parent = nullptr);
    void start(quint16 port);
    void stop();

signals:
    void clientConnected(QTcpSocket *socket);

private:
    QTcpServer m_server;
};

#endif // MIRRORSERVER_H
