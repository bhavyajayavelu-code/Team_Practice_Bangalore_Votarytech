#include "MirrorServer.h"
#include <QDebug>

MirrorServer::MirrorServer(QObject *parent) : QObject(parent) {
    connect(&m_server, &QTcpServer::newConnection, this, [this]() {
        auto *socket = m_server.nextPendingConnection();
        emit clientConnected(socket);
    });
}

void MirrorServer::start(quint16 port) {
    bool ok =m_server.listen(QHostAddress::Any, port);
    // bool ok = m_server.listen(QHostAddress::AnyIPv4, port);
    qDebug() << "Listening on port 5000:" << m_server.isListening();
    qDebug() << "Listening on port second debug 5000:" << ok;

    if (!ok) {
        qDebug() << "Server error:" << m_server.errorString();
    }
}

void MirrorServer::stop() {
    m_server.close();
}
