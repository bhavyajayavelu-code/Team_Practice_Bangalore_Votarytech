#include <QMutexLocker>
#include "mirrorimageprovider.h"

MirrorImageProvider::MirrorImageProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage MirrorImageProvider::requestImage(const QString &id,
                                         QSize *size,
                                         const QSize &)
{
    Q_UNUSED(id);
    QMutexLocker lock(&m_mutex);


    if (m_image.isNull()) {

        QImage dummy(640, 480, QImage::Format_RGB32);
        dummy.fill(Qt::black);

        if (size)
            *size = dummy.size();

        return dummy;
    }

    if (size)
        *size = m_image.size();

    return m_image;
}

void MirrorImageProvider::updateImage(const QImage &image)
{
    QMutexLocker lock(&m_mutex);
    // m_image = image.copy();
    m_image = image;


}

void MirrorImageProvider::clear()
{
    QMutexLocker lock(&m_mutex);
    m_image = QImage();   // HARD RESET
}
