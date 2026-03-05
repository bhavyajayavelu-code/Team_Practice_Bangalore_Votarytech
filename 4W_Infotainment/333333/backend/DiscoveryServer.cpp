#include "DiscoveryServer.h"
#include <QHostAddress>
#include <QDebug>

DiscoveryServer::DiscoveryServer(quint16 port, QObject *parent)
    : QObject(parent),
    mirrorPort(port)
{
    udpSocket = new QUdpSocket(this);

    udpSocket->bind(QHostAddress::AnyIPv4,
                    45454,
                    QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint);

    connect(udpSocket, &QUdpSocket::readyRead,
            this, &DiscoveryServer::processPendingDatagrams);

    qDebug() << "Discovery server listening on UDP 45454";
}

void DiscoveryServer::processPendingDatagrams()
{
    while (udpSocket->hasPendingDatagrams()) {

        QByteArray datagram;
        datagram.resize(udpSocket->pendingDatagramSize());

        QHostAddress sender;
        quint16 senderPort;

        udpSocket->readDatagram(datagram.data(),
                                datagram.size(),
                                &sender,
                                &senderPort);

        if (datagram == "WHO_IS_MIRROR") {
            qDebug() << "WHO_IS_MIRROR condition satisfied" << sender;
            QByteArray response =
                "MIRROR_DEVICE:OKT507:" +
                QByteArray::number(mirrorPort);

            udpSocket->writeDatagram(response,
                                     sender,
                                     senderPort);

            qDebug() << "Discovery response sent to" << sender;
        }
    }
}
