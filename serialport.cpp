#include "serialport.h"
#include <QSerialPortInfo>
#include <QDebug>

static const char NA[] = "N/A";

SerialPort::SerialPort(QObject *parent) : QSerialPort(parent),
    mIsConnected(false)
{
    refreshPortInfo();
}

QString SerialPort::currentPort()
{
    return mPortName;
}

void SerialPort::setCurrentPort(QString name)
{
    mPortName = name;
    setPortName(name);
    emit currentPortChanged();
}

void SerialPort::setData(const QString data)
{
    mData = data;
    if(isOpen()) {
        qDebug() << "Data sent: " << data.toUtf8();
        write(data.toUtf8());
    }
}

QStringList SerialPort::availablePorts()
{
    return mPorts;
}

QStringList SerialPort::portsInfo()
{
    return mPortsInfo;
}

QStringList SerialPort::plotLabels()
{
    return mPlotLabels;
}

QString SerialPort::data()
{
    return mData;
}

QVector<int> SerialPort::lastPoint()
{
    return mValues;
}

bool SerialPort::isConnected()
{
    return mIsConnected;
}

void SerialPort::refreshPortInfo()
{
    QString description;
    QString manufacturer;
    QString serialNumber;
    mPorts.clear();
    mPortsInfo.clear();

    const auto infos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : infos) {
        QString list;
        description = info.description();
        manufacturer = info.manufacturer();
        serialNumber = info.serialNumber();

        list = QString("Port Name: %1\nDescription: %2 \nManufacturer: %3 \n"
                       "Serial Nº: %4 \nLocation: %5 \nVendor id: %6 \nProduct id: %7")
                .arg(description.isEmpty() ? description : NA)
                .arg(manufacturer.isEmpty() ? manufacturer : NA)
                .arg(serialNumber.isEmpty() ? serialNumber : NA)
                .arg(info.systemLocation())
                .arg(info.vendorIdentifier() ? QString::number(info.vendorIdentifier(), 16) : NA)
                .arg(info.productIdentifier() ? QString::number(info.productIdentifier(), 16) : NA);

        mPorts.append(info.portName());
        mPortsInfo.append(list);
    }
    emit availablePortsChanged();
    emit portsInfoChanged();
}

void SerialPort::connectSerial()
{
    qDebug() << currentPort() <<baudRate() << dataBits() << stopBits() << flowControl() << parity();
    if(!isOpen()) {
        mIsConnected = open(QIODevice::ReadWrite);
        isConnectedChanged();
    }
    else {
        qDebug() << "Serial still open!";
    }
}

void SerialPort::disconnectSerial()
{
    if(isOpen()) {
        close();
        mIsConnected = false;
        emit isConnectedChanged();
    }
}

void SerialPort::readyReadSlot()
{
    while(canReadLine()) {
        mData = QString(readLine());
        emit dataChanged();
        qDebug() <<  mData;
        // Caso haja varios dados, separar cada um deles com ';'
        auto varList = QString(mData).split(';',QString::SkipEmptyParts);
        // Para cada um dos dados, separar Label e respetivo valor "Label=Value"
        for(auto &var : varList) {
            auto varSplit = var.remove(QRegExp("[\n\r ]")).split('=', QString::SkipEmptyParts);

            // Parse do label e do valor
            if(varSplit.size() == 2) {
                QString label = varSplit.at(0);
                if(!mPlotLabels.contains(label)) {
                    mPlotLabels.append(label);
                    emit plotLabelsChanged();
                }
                bool okPtr = false;
                double x = varSplit.at(1).toDouble(&okPtr);
                if (okPtr)
                    mValues.append(static_cast<int>(x));
            }
        }
        // No fim de processar uma linha, enviar valores para QML
        if(!mValues.isEmpty()) {
            emit lastPointChanged();
            qDebug() << mValues;
            mValues.clear();
        }
    }
}

void SerialPort::clearPlotLabels()
{
    mPlotLabels.clear();
}
