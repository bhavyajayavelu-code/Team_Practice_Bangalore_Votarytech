#include"TcpWorker.h"
#include <QHostAddress>
#include <QImage>
#include <QQuickImageProvider>
#include <QTimer>
// TcpWorker.cpp
TcpWorker::TcpWorker(QTcpSocket *socket, QObject *parent)
    : QObject(parent), m_socket(socket)
{
    qDebug() << "TcpWorker thread:" << QThread::currentThread();
    qDebug() << "Socket thread   :" << m_socket->thread();
    m_renderTimer = new QTimer(this);
    connect(m_socket, &QTcpSocket::readyRead,
            this, &TcpWorker::onReadyRead);
    connect(m_socket, &QTcpSocket::disconnected,
            this, &TcpWorker::onDisconnected);
    connect(m_renderTimer, &QTimer::timeout,
            this, &TcpWorker::processLatestFrame);
    m_renderTimer->start(45); //delay for fps renedering //            	30 FPS → 33 ms  20 FPS → 50 ms  15 FPS → 66 ms


}

void TcpWorker::onReadyRead()
{
    qDebug() << "onReadyRead thread:" << QThread::currentThread();
    m_buffer.append(m_socket->readAll());

    while (true) {
        if (m_expectedSize < 0) {
            if (m_buffer.size() < 4) return;

            QDataStream ds(m_buffer.left(4));
            ds.setByteOrder(QDataStream::BigEndian);
            ds >> m_expectedSize;
            m_buffer.remove(0, 4);
        }

        if (m_buffer.size() < m_expectedSize) return;

        QByteArray jpeg = m_buffer.left(m_expectedSize);
        m_buffer.remove(0, m_expectedSize);
        m_expectedSize = -1;

        // overwrite old frame
        {
            QMutexLocker lock(&m_frameMutex);
            m_latestFrame = jpeg;
        }
    }
}

void TcpWorker::processLatestFrame()
{
    qDebug() << "processLatestFrame thread:" << QThread::currentThread();
    if (m_busy.load())
        return;

    QByteArray frameCopy;
    {
        QMutexLocker lock(&m_frameMutex);
        if (m_latestFrame.isEmpty())
            return;
        frameCopy = m_latestFrame;
    }

    m_busy.store(true);

    QImage img;
    img.loadFromData(frameCopy, "JPG");

    if (!img.isNull())
        emit frameReady(img);  // UI-safe

    m_busy.store(false);
}


void TcpWorker::onDisconnected() {
    m_socket->deleteLater();
    deleteLater();
}
