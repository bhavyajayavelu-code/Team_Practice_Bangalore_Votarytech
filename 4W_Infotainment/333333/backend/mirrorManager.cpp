#include "mirrorManager.h"
#include "mirrorimageprovider.h"
#include "TcpWorker.h"
#include <QDebug>
#include <QPainter>
#include <QProcess>
#include <QTimer>
#include <QBuffer>
#include "DiscoveryServer.h"
#ifdef Q_OS_ANDROID
#include <QAndroidJniObject>
#include <QtAndroid>
#include <jni.h>
#include <QAndroidJniEnvironment>
#endif

MirrorManager::MirrorManager(QObject *parent)
    : QObject(parent)
{
    m_provider = new MirrorImageProvider;

    connect(&m_server, &MirrorServer::clientConnected,
            this, [this](QTcpSocket *socket) {

                m_currentWorker = new TcpWorker(socket, this);

                connect(m_currentWorker, &TcpWorker::frameReady,
                        this, [this](const QImage &img) {

                            if (!m_mirroring.loadAcquire())
                                return;

                            m_provider->updateImage(img);

                            emit frameUpdated();

                        }, Qt::QueuedConnection);
            });

    m_server.start(5000);

    m_discovery = new DiscoveryServer(5000, this);

}
MirrorImageProvider *MirrorManager::imageProvider() const
{
    return m_provider;
}


QImage MirrorManager::frame() const
{
    QMutexLocker lock(&m_mutex);
    return m_frame;
}

void MirrorManager::startMirroring()
{
    if (m_mirroring)
        return;

    m_mirroring.storeRelease(true);


    emit mirroringChanged();
}

void MirrorManager::stopMirroring()
{
    if (!m_mirroring)
        return;

    // m_mirroring = false;
    m_mirroring.storeRelease(false);

    if (m_currentWorker) {
        m_currentWorker->deleteLater();
        m_currentWorker = nullptr;
    }

    m_provider->clear();

    emit frameUpdated();
    emit mirroringChanged();

}
