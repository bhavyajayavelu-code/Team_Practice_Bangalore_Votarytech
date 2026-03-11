#include "WifiManager.h"
#include <QDebug>
#include <QtAndroid>
#include <QAndroidJniObject>
#include <QAndroidJniEnvironment>
#include <QtAndroidExtras>
#include <QTimer>
#include <QSet> // <--- NEW: For filtering duplicates

// --- WifiModel Implementation ---
WifiModel::WifiModel(QObject *parent) : QAbstractListModel(parent) {}

void WifiModel::setNetworks(const QList<WifiNetwork> &networks) {
    beginResetModel();
    m_networks = networks;
    endResetModel();
}

void WifiModel::clear() {
    beginResetModel();
    m_networks.clear();
    endResetModel();
}

int WifiModel::rowCount(const QModelIndex &) const {
    return m_networks.count();
}

QVariant WifiModel::data(const QModelIndex &index, int role) const {
    if (!index.isValid() || index.row() >= m_networks.count())
        return QVariant();

    const WifiNetwork &network = m_networks[index.row()];
    switch (role) {
    case SsidRole: return network.ssid;
    case BssidRole: return network.bssid;
    case SignalRole: return network.signalLevel;
    case CapabilitiesRole: return network.capabilities;
    case SecuredRole: return network.isSecured;
    default: return QVariant();
    }
}

QHash<int, QByteArray> WifiModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[SsidRole] = "ssid";
    roles[BssidRole] = "bssid";
    roles[SignalRole] = "signalLevel";
    roles[CapabilitiesRole] = "capabilities";
    roles[SecuredRole] = "isSecured";
    return roles;
}

// --- WifiManager Implementation ---
WifiManager::WifiManager(QObject *parent) : QObject(parent) {
    m_wifiModel = new WifiModel(this);
    m_connectionStatus = "Disconnected";

    // Check status every 2 seconds
    m_statusTimer = new QTimer(this);
    connect(m_statusTimer, &QTimer::timeout, this, &WifiManager::checkRealConnection);
    m_statusTimer->start(2000);
}

WifiManager::~WifiManager() {}

void WifiManager::setConnectionStatus(const QString &status) {
    if (m_connectionStatus != status) {
        m_connectionStatus = status;
        emit connectionStatusChanged();
    }
}

// --- REAL STATUS CHECKER (FIXED GLITCH LOGIC) ---
void WifiManager::checkRealConnection() {
    QAndroidJniObject activity = QtAndroid::androidActivity();
    if (!activity.isValid()) return;

    QAndroidJniObject wifiMgr = activity.callObjectMethod("getSystemService",
                                                          "(Ljava/lang/String;)Ljava/lang/Object;",
                                                          QAndroidJniObject::fromString("wifi").object());

    if (!wifiMgr.isValid()) return;

    QAndroidJniObject wifiInfo = wifiMgr.callObjectMethod("getConnectionInfo", "()Landroid/net/wifi/WifiInfo;");
    if (!wifiInfo.isValid()) return;

    QString ssid = wifiInfo.callObjectMethod("getSSID", "()Ljava/lang/String;").toString();
    QAndroidJniObject stateObj = wifiInfo.callObjectMethod("getSupplicantState", "()Landroid/net/wifi/SupplicantState;");
    QString state = stateObj.callObjectMethod("toString", "()Ljava/lang/String;").toString();

    // Clean up SSID
    if (ssid.startsWith("\"") && ssid.endsWith("\"")) {
        ssid = ssid.mid(1, ssid.length() - 2);
    }

    // --- FIX 2: GLITCH PREVENTION ---
    // Only update to "Disconnected" if we aren't currently trying to connect.
    // If status is "Initiating...", we ignore the "DISCONNECTED" signal from Android
    // because it's likely just the brief gap before the new connection starts.

    if (state == "COMPLETED") {
        setConnectionStatus("Connected to " + ssid);
    }
    else if (state == "ASSOCIATING" || state == "AUTHENTICATING" || state == "FOUR_WAY_HANDSHAKE") {
        setConnectionStatus("Authentication...");
    }
    else if (state == "DISCONNECTED" || state == "INACTIVE" || state == "SCANNING") {
        // If we are currently "Connected", allow it to drop to Disconnected.
        // If we are "Initiating...", keep showing that until we succeed or fail hard.
        if (!m_connectionStatus.startsWith("Initiating")) {
            setConnectionStatus("Disconnected");
        }
    }
}

void WifiManager::scanForNetworks() {
    setConnectionStatus("Scanning...");
    m_wifiModel->clear();

    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject wifiManager = activity.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        QAndroidJniObject::fromString("wifi").object()
        );

    if (!wifiManager.isValid()) {
        setConnectionStatus("Error: WiFi Service Not Found");
        return;
    }

    wifiManager.callMethod<jboolean>("startScan");
    QTimer::singleShot(2000, this, &WifiManager::handleScanResults);
}

void WifiManager::handleScanResults() {
    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject wifiManager = activity.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        QAndroidJniObject::fromString("wifi").object()
        );

    QAndroidJniObject scanResults = wifiManager.callObjectMethod("getScanResults", "()Ljava/util/List;");
    if (!scanResults.isValid()) return;

    int count = scanResults.callMethod<jint>("size");
    QList<WifiNetwork> networks;
    QSet<QString> seenSsids; // --- FIX 1: DUPLICATE FILTER ---

    for (int i = 0; i < count; ++i) {
        QAndroidJniObject result = scanResults.callObjectMethod("get", "(I)Ljava/lang/Object;", i);
        QString ssid = result.getObjectField<jstring>("SSID").toString();
        QString caps = result.getObjectField<jstring>("capabilities").toString();
        int level = result.getField<jint>("level");

        // Filter duplicates and empty names
        if (!ssid.isEmpty() && !seenSsids.contains(ssid)) {
            seenSsids.insert(ssid); // Remember this Name

            WifiNetwork network;
            network.ssid = ssid;
            network.bssid = ""; // Not needed for UI
            network.signalLevel = (level > -50) ? 4 : (level > -60) ? 3 : (level > -70) ? 2 : 1;
            network.capabilities = caps;
            network.isSecured = caps.contains("WPA") || caps.contains("WEP") || caps.contains("EAP");

            networks.append(network);
        }
    }

    m_wifiModel->setNetworks(networks);
    emit scanFinished();
}

void WifiManager::connectToNetwork(const QString &ssid, const QString &password) {
    setConnectionStatus("Initiating Connection...");

    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject wifiManager = activity.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        QAndroidJniObject::fromString("wifi").object()
        );

    QAndroidJniObject wifiConfig("android/net/wifi/WifiConfiguration");
    QAndroidJniEnvironment env;
    jclass configClass = env->GetObjectClass(wifiConfig.object());

    // Set SSID
    QAndroidJniObject ssidStr = QAndroidJniObject::fromString("\"" + ssid + "\"");
    jfieldID ssidField = env->GetFieldID(configClass, "SSID", "Ljava/lang/String;");
    env->SetObjectField(wifiConfig.object(), ssidField, ssidStr.object());

    // Handle Password
    if (password.isEmpty()) {
        QAndroidJniObject allowedKeyManagement = wifiConfig.getObjectField("allowedKeyManagement", "Ljava/util/BitSet;");
        allowedKeyManagement.callMethod<void>("set", "(I)V", 0);
    } else {
        QAndroidJniObject passStr = QAndroidJniObject::fromString("\"" + password + "\"");
        jfieldID keyField = env->GetFieldID(configClass, "preSharedKey", "Ljava/lang/String;");
        env->SetObjectField(wifiConfig.object(), keyField, passStr.object());
    }

    int netId = wifiManager.callMethod<jint>("addNetwork", "(Landroid/net/wifi/WifiConfiguration;)I", wifiConfig.object());

    if (netId != -1) {
        wifiManager.callMethod<jboolean>("disconnect");
        wifiManager.callMethod<jboolean>("enableNetwork", "(IZ)Z", netId, true);
        wifiManager.callMethod<jboolean>("reconnect");
        // Status will be updated by checkRealConnection()
    } else {
        setConnectionStatus("Configuration Failed");
    }
}

void WifiManager::disconnect() {
    QAndroidJniObject activity = QtAndroid::androidActivity();
    QAndroidJniObject wifiManager = activity.callObjectMethod(
        "getSystemService",
        "(Ljava/lang/String;)Ljava/lang/Object;",
        QAndroidJniObject::fromString("wifi").object()
        );
    wifiManager.callMethod<jboolean>("disconnect");
    setConnectionStatus("Disconnected");
}
