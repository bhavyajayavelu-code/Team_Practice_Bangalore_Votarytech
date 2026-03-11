#ifndef WIFIMANAGER_H
#define WIFIMANAGER_H

#include <QObject>
#include <QVariantList>
#include <QAbstractListModel>
#include <QTimer> // <--- NEW: Needed for polling status

// A simple structure to hold network info
struct WifiNetwork {
    QString ssid;
    QString bssid;
    int signalLevel;
    QString capabilities;
    bool isSecured; // <--- NEW: Tells QML if it needs a lock icon
};

// A model to feed the ListView in QML
class WifiModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum WifiRoles {
        SsidRole = Qt::UserRole + 1,
        BssidRole,
        SignalRole,
        CapabilitiesRole,
        SecuredRole // <--- NEW: Exposes security status to QML
    };

    explicit WifiModel(QObject *parent = nullptr);

    void setNetworks(const QList<WifiNetwork> &networks);
    void clear();

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;

private:
    QList<WifiNetwork> m_networks;
};

class WifiManager : public QObject
{
    Q_OBJECT
    // Expose the model to QML so the ListView can use it
    Q_PROPERTY(WifiModel* wifiModel READ wifiModel CONSTANT)
    // Expose connection status
    Q_PROPERTY(QString connectionStatus READ connectionStatus NOTIFY connectionStatusChanged)

public:
    explicit WifiManager(QObject *parent = nullptr);
    ~WifiManager();

    WifiModel* wifiModel() const { return m_wifiModel; }
    QString connectionStatus() const { return m_connectionStatus; }

    // Functions callable from QML
    Q_INVOKABLE void scanForNetworks();
    Q_INVOKABLE void connectToNetwork(const QString &ssid, const QString &password);
    Q_INVOKABLE void disconnect();

signals:
    void connectionStatusChanged();
    void scanFinished();

private slots:
    void handleScanResults();
    void checkRealConnection(); // <--- NEW: The "Truth Checker" function

private:
    WifiModel* m_wifiModel;
    QString m_connectionStatus;
    QTimer *m_statusTimer; // <--- NEW: The timer that runs every 2 seconds
    void setConnectionStatus(const QString &status);
};

#endif // WIFIMANAGER_H
