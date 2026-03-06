#ifndef TCPWORKER_H // TCPWORKER_H
#define TCPWORKER_H
#include <QNetworkAccessManager>
#include <QObject>
#include <QTcpSocket>
#include <QThread>
#include <QMutexLocker>
#include <QTimer>
#include <atomic>
#pragma once

#include <QObject>
#include <QTcpSocket>
#include <QTimer>
#include <QMutex>
#include <QByteArray>
#include <atomic>

class TcpWorker : public QObject
{
    Q_OBJECT
public:
    explicit TcpWorker(QTcpSocket *socket, QObject *parent = nullptr);

signals:
    void frameReady(const QImage &img);

private slots:
    void onReadyRead();
    void onDisconnected();
    void processLatestFrame();

private:
    QTcpSocket *m_socket;

    QByteArray m_buffer;
    int m_expectedSize = -1;

    QByteArray m_latestFrame;
    QMutex m_frameMutex;

    std::atomic_bool m_busy{false};
    QTimer *m_renderTimer = nullptr;
};


#endif // TCPWORKER_H
