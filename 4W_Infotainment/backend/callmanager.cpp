/*#include "callmanager.h"
#include <QDebug>
#include <QProcess>

CallManager::CallManager(QObject *parent)
    : QObject(parent)
{
    qDebug() << "CallManager constructed";
}

void CallManager::makeCall(const QString &number)
{
    qDebug() << "========== MAKECALL CALLED ==========";
    qDebug() << "Number to call:" << number;

#ifdef Q_OS_ANDROID
    qDebug() << "Android detected - Using ecall helper script";

    QString scriptPath = "/data/local/tmp/ecall_dial.sh";
    QString command = scriptPath + " " + number;

    QProcess process;
    //process.start("su", QStringList() << "-c" << command);
    process.start(scriptPath, QStringList() << number);

    if (process.waitForFinished(8000)) {
        int exitCode = process.exitCode();
        QByteArray output = process.readAll();
        QByteArray error = process.readAllStandardError();

        qDebug() << "Exit code:" << exitCode;
        qDebug() << "Output:" << output;
        qDebug() << "Error:" << error;

        if (exitCode == 0) {
            qDebug() << "✅ Call initiated successfully";
            emit callInitiated(number);
        } else {
            qDebug() << "❌ Call initiation failed";
            emit callFailed(number, "Script execution failed");
        }
    } else {
        qDebug() << "❌ Process timed out";
        process.kill();
        emit callFailed(number, "Timeout");
    }
#endif
}*/

#include "callmanager.h"
#include <QDebug>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QTimer>
#include <QThread>

CallManager::CallManager(QObject *parent)
    : QObject(parent)
{
    qDebug() << "CallManager constructed";
    m_vehicleId = "OKT507C-001";
}

void CallManager::makeCall(const QString &number)
{
    qDebug() << "========== MAKECALL CALLED ==========";
    qDebug() << "Number to call:" << number;

#ifdef Q_OS_ANDROID
    QSerialPort modem;
    modem.setPortName("/dev/ttyUSB2");
    modem.setBaudRate(QSerialPort::Baud115200);
    modem.setDataBits(QSerialPort::Data8);
    modem.setParity(QSerialPort::NoParity);
    modem.setStopBits(QSerialPort::OneStop);
    modem.setFlowControl(QSerialPort::NoFlowControl);

    if (!modem.open(QIODevice::ReadWrite)) {
        qDebug() << "❌ Failed to open modem port!";
        qDebug() << "Error:" << modem.errorString();
        emit callFailed(number, "Failed to open modem: " + modem.errorString());
        return;
    }

    qDebug() << "✅ Modem port opened successfully";

    // Basic AT check
    modem.write("AT\r");
    modem.waitForBytesWritten(1000);
    modem.waitForReadyRead(2000);
    QByteArray response = modem.readAll();
    qDebug() << "Modem Response:" << response;

    // Dial command
    QString command = "ATD" + number + ";\r";
    modem.write(command.toUtf8());
    modem.waitForBytesWritten(3000);

    qDebug() << "📞 AT Call command sent:" << command;
    modem.close();

    emit callInitiated(number);
#endif
}

void CallManager::sendEmergencySMS(const QString &number, const QString &message)
{
    qDebug() << "========== SEND EMERGENCY SMS ==========";
    qDebug() << "To:" << number;
    qDebug() << "Message:" << message;

#ifdef Q_OS_ANDROID
    QSerialPort modem;
    modem.setPortName("/dev/ttyUSB2");
    modem.setBaudRate(QSerialPort::Baud115200);
    modem.setDataBits(QSerialPort::Data8);
    modem.setParity(QSerialPort::NoParity);
    modem.setStopBits(QSerialPort::OneStop);
    modem.setFlowControl(QSerialPort::NoFlowControl);

    if (!modem.open(QIODevice::ReadWrite)) {
        qDebug() << "❌ Failed to open modem port for SMS!";
        emit smsSent(number, false);
        return;
    }

    qDebug() << "✅ Modem opened for SMS";

    // UCS2 formats for your number 9322403981
    QString numberUCS2 = "0039003300320032003400300033003900380031";
    QString smsCenterUCS2 = "002B003900310039003800340039003000380037003000300031";

    // Set SMS center (UCS2 format)
    modem.write("AT+CSCA=\"" + smsCenterUCS2.toUtf8() + "\",145\r");
    modem.waitForBytesWritten(1000);
    QThread::sleep(2);

    // Set character set to UCS2
    modem.write("AT+CSCS=\"UCS2\"\r");
    modem.waitForBytesWritten(1000);
    QThread::sleep(2);

    // Set text mode
    modem.write("AT+CMGF=1\r");
    modem.waitForBytesWritten(1000);
    QThread::sleep(2);

    // Prepare SMS with UCS2 number
    modem.write("AT+CMGS=\"" + numberUCS2.toUtf8() + "\"\r");
    modem.waitForBytesWritten(1000);
    QThread::sleep(3);

    // Convert message to UCS2 (simplified - for English characters)
    QString ucs2Message;
    for (QChar ch : message) {
        ucs2Message += QString("00%1").arg(ch.unicode(), 2, 16, QChar('0')).toUpper();
    }

    // Send message with Ctrl+Z
    modem.write(ucs2Message.toUtf8() + "\x1A");
    modem.waitForBytesWritten(1000);
    QThread::sleep(5);

    modem.close();
    emit smsSent(number, true);
#endif
}

void CallManager::triggerEmergency(const QString &number)
{
    Q_UNUSED(number)
    qDebug() << "========== 🚨 EMERGENCY TRIGGERED ==========";

    QString fixedNumber = "9322403981";
    QString location = "12.984593,77.7337515";

    // First make the call
    makeCall(fixedNumber);

    // Wait a bit then send SMS
    QTimer::singleShot(5000, [this, fixedNumber, location]() {
        QString message = QString("EMERGENCY! Vehicle:%1 Location:Whitefield,Bangalore %2")
        .arg(m_vehicleId)
            .arg(location);
        sendEmergencySMS(fixedNumber, message);

        emit emergencyTriggered(fixedNumber, location);
    });
}

void CallManager::makeEmergencyCall(const QString &number)
{
    makeCall(number);
}

void CallManager::setVehicleId(const QString &id)
{
    if (m_vehicleId != id) {
        m_vehicleId = id;
        emit vehicleIdChanged(id);
        qDebug() << "🚗 Vehicle ID set to:" << id;
    }
}
