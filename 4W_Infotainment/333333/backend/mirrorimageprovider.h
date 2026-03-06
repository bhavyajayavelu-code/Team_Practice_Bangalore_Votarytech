#ifndef MIRRORIMAGEPROVIDER_H
#define MIRRORIMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QImage>
#include <QMutex>

class MirrorImageProvider : public QQuickImageProvider
{
public:
    MirrorImageProvider();

    QImage requestImage(const QString &id,
                        QSize *size,
                        const QSize &requestedSize) override;

    void updateImage(const QImage &image);
    void clear();

private:
    QImage m_image;
    QMutex m_mutex;
};

#endif // MIRRORIMAGEPROVIDER_H
