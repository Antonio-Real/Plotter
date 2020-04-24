#ifndef SERIALPORT_H
#define SERIALPORT_H

#include <QSerialPort>
#include <QVector>

class SerialPort : public QSerialPort
{
    Q_OBJECT

    Q_PROPERTY(QString currentPort READ currentPort WRITE setCurrentPort NOTIFY currentPortChanged)
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(QStringList portsInfo READ portsInfo NOTIFY portsInfoChanged)
    Q_PROPERTY(QStringList plotLabels READ plotLabels NOTIFY plotLabelsChanged)
    Q_PROPERTY(QVector<int> lastPoint READ lastPoint NOTIFY lastPointChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)

public:
    explicit SerialPort(QObject *parent = nullptr);

    QString currentPort();
    void setCurrentPort(QString name);
    QStringList availablePorts();
    QStringList portsInfo();
    QStringList plotLabels();
    QVector<int> lastPoint();
    bool isConnected();

signals:
    void currentPortChanged(QString &);
    void availablePortsChanged(QStringList &);
    void portsInfoChanged(QStringList &);
    void plotLabelsChanged(QStringList &);
    void lastPointChanged(QVector<int> &);
    void isConnectedChanged(bool &);

public slots:
    void refreshPortInfo();
    void connectSerial();
    void disconnectSerial();
    void readyReadSlot();
    void clearPlotLabels();

private:
    QString mPortName;
    QStringList mPorts;
    QStringList mPortsInfo;
    QStringList mPlotLabels;
    QVector<int> mValues;
    bool mIsConnected;

};

#endif // SERIALPORT_H
