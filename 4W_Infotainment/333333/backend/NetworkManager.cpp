#include "NetworkManager.h"
#include <QClipboard>
#include <QGuiApplication>
#include <QDebug>
#include <QTimer>  // Added missing include

NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent)
    , m_ipAddress("Checking...")
    , m_networkType("Disconnected")
    , m_networkName("No network")
    , m_isConnected(false)
{
    m_updateTimer = new QTimer(this);
    connect(m_updateTimer, &QTimer::timeout, this, &NetworkManager::updateNetworkInfo);
    m_updateTimer->start(3000); // Update every 3 seconds

    // Initial detection
    updateNetworkInfo();
}

void NetworkManager::updateNetworkInfo()
{
    detectNetworkInfo();
}

void NetworkManager::detectNetworkInfo()
{
    QString previousIP = m_ipAddress;
    QString previousType = m_networkType;
    bool previousConnected = m_isConnected;

    // Clear previous data
    QString newIP = "No connection";
    QString newType = "Disconnected";
    QString newName = "No network";
    bool newConnected = false;

    // Get all network interfaces
    QList<QNetworkInterface> interfaces = QNetworkInterface::allInterfaces();

    for (const QNetworkInterface &interface : interfaces) {
        // Skip loopback and disabled interfaces
        if (!(interface.flags() & QNetworkInterface::IsUp) ||
            !(interface.flags() & QNetworkInterface::IsRunning) ||
            (interface.flags() & QNetworkInterface::IsLoopBack)) {
            continue;
        }

        // Get interface type
        QString type = getInterfaceType(interface);

        // Get IPv4 addresses for this interface
        QList<QNetworkAddressEntry> entries = interface.addressEntries();
        for (const QNetworkAddressEntry &entry : entries) {  // Fixed: entries not entry
            QHostAddress ip = entry.ip();

            // Check if it's IPv4 (not IPv6)
            if (ip.protocol() == QAbstractSocket::IPv4Protocol) {
                QString ipString = ip.toString();

                // Skip private/link-local addresses if we want public IP
                // For local network display, include all
                if (!ipString.startsWith("169.254") && // Link-local
                    !ipString.startsWith("127.")) {     // Loopback

                    newIP = ipString;
                    newType = type;
                    newName = interface.humanReadableName();

                    // Try to get better network name
                    if (newName.isEmpty()) {
                        newName = interface.name();
                    }

                    newConnected = true;
                    break; // Found valid address for this interface
                }
            }
        }

        if (newConnected) {
            break; // Found valid interface, no need to check others
        }
    }

    // Update member variables
    bool ipChanged = (m_ipAddress != newIP);
    bool typeChanged = (m_networkType != newType);
    bool nameChanged = (m_networkName != newName);
    bool connectedChanged = (m_isConnected != newConnected);

    m_ipAddress = newIP;
    m_networkType = newType;
    m_networkName = newName;
    m_isConnected = newConnected;

    // Emit signals if values changed
    if (ipChanged) {
        emit ipAddressChanged();
    }
    if (typeChanged) {
        emit networkTypeChanged();
    }
    if (nameChanged) {
        emit networkNameChanged();
    }
    if (connectedChanged) {
        emit connectionChanged();
    }

    // Log changes
    if (ipChanged || typeChanged || nameChanged || connectedChanged) {
        qDebug() << "Network info updated:"
                 << "IP:" << m_ipAddress
                 << "Type:" << m_networkType
                 << "Name:" << m_networkName
                 << "Connected:" << m_isConnected;
    }
}

QString NetworkManager::getInterfaceType(const QNetworkInterface &interface)
{
    QString name = interface.name().toLower();
    QString humanName = interface.humanReadableName().toLower();

    // Check for WiFi interfaces
    if (name.contains("wlan") || name.contains("wifi") ||
        name.contains("wireless") || humanName.contains("wireless") ||
        name.contains("wi-fi") ||
        interface.type() == QNetworkInterface::Wifi) {
        return "Wi-Fi";
    }

    // Check for Ethernet interfaces
    else if (name.contains("eth") || name.contains("ethernet") ||
             name.contains("en") || name.startsWith("eth") ||
             interface.type() == QNetworkInterface::Ethernet) {
        return "Ethernet";
    }

    // Check for cellular/mobile data (using string matching only for older Qt)
    else if (name.contains("wwan") || name.contains("cellular") ||
             name.contains("mobile")) {
        // For Qt < 5.15, we can't use QNetworkInterface::Wwan
        // So we rely on name matching only
        return "Mobile Data";
    }

    // USB tethering
    else if (name.contains("usb") || humanName.contains("usb")) {
        return "USB Tethering";
    }

    // Bluetooth
    else if (name.contains("bt") || name.contains("bluetooth")) {
        return "Bluetooth";
    }

    // Virtual/VPN interfaces
    else if (name.contains("tun") || name.contains("tap") ||
             name.contains("vpn") || name.contains("virtual")) {
        return "Virtual";
    }

    // Check for PPP (Point-to-Point Protocol) - often used for mobile data
    else if (name.contains("ppp") || name.contains("gsm") ||
             name.contains("3g") || name.contains("4g") || name.contains("5g")) {
        return "Mobile Data";
    }

    // Unknown/other
    return "Network";
}

void NetworkManager::refreshNetworkInfo()
{
    qDebug() << "Manual network refresh requested";
    updateNetworkInfo();
}

QString NetworkManager::copyToClipboard(const QString &text)
{
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setText(text);
    qDebug() << "Copied to clipboard:" << text;
    return "Copied to clipboard!";
}
