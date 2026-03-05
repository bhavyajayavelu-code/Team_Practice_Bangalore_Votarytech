#ifndef MIRRORMANAGER_H
#define MIRRORMANAGER_H

#include <QObject>
#include <QImage>
#include <QMutex>
#include <QAtomicInteger>
#include "MirrorServer.h"
#include "TcpWorker.h"
#include "mirrorimageprovider.h"
#include "DiscoveryServer.h"
class MirrorManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool mirroring READ mirroring NOTIFY mirroringChanged)
    Q_PROPERTY(QImage frame READ frame NOTIFY frameUpdated)

public:
    explicit MirrorManager(QObject *parent = nullptr);

    bool mirroring() const { return m_mirroring.loadAcquire(); }
    QImage frame() const;
    MirrorImageProvider *imageProvider() const;
signals:
    void frameUpdated();
    void mirroringChanged();

public slots:
    void startMirroring();
    void stopMirroring();

private:
    QImage m_frame;
    mutable QMutex m_mutex;
    QAtomicInteger<bool> m_mirroring { false };
    MirrorImageProvider *m_provider;
    MirrorServer m_server;
    DiscoveryServer *m_discovery;
    TcpWorker* m_currentWorker = nullptr;
};

#endif
