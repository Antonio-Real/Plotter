import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import QtCharts 2.3
import components.serial 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Serial Plotter")

    ChartView {
        id: viewPort
        anchors.fill: parent
        antialiasing: true
        dropShadowEnabled: true
        theme: ChartView.ChartThemeDark

        ValueAxis {
            id: axisX
            min: 0
            max: 10
            labelFormat: "%d"
            labelsFont: Qt.font({pointSize: 10})
            titleText: "Seconds (s)"
        }
        ValueAxis {
            id: axisY
            min: 0
            max: 10
            labelFormat: "%d"
            labelsFont: Qt.font({pointSize: 10})
            titleText: "Units (?)"
        }
    }

    Dialog {
        id: diag
        anchors.centerIn: parent
        title: "Configure serial settings"
        modal: true
        standardButtons: Dialog.Save
        closePolicy: Popup.NoAutoClose

        RowLayout {
            anchors.fill: parent

            Column {
                Layout.fillHeight: true
                Layout.fillWidth: true
                Label { id: portInfoLabel }
            }

            Column {
                Label { text: "Name" }
                ComboBox {
                    id: serialPortName
                    model: serialManager.availablePorts
                    onCurrentTextChanged: {
                        portInfoLabel.text = serialManager.portsInfo[currentIndex]
                    }
                }
                Label { text: "BaudRate" }
                ComboBox {
                    id: serialBaud
                    model: [SerialPort.Baud9600,
                        SerialPort.Baud38400,
                        SerialPort.Baud57600,
                        SerialPort.Baud115200]
                    Component.onCompleted: currentIndex = 3
                }
                Label { text: "Data Bits" }
                ComboBox {
                    id: serialDataBits
                    model: [SerialPort.Data5,
                        SerialPort.Data6,
                        SerialPort.Data7,
                        SerialPort.Data8]
                    Component.onCompleted: currentIndex = 3;
                }
                Label { text: "Parity" }
                ComboBox {
                    id: serialParity
                    textRole: "text"
                    model: [{ value: SerialPort.NoParity, text: "None" },
                        { value: SerialPort.EvenParity, text: "Even" },
                        { value: SerialPort.OddParity, text: "Odd" },
                        { value: SerialPort.MarkParity, text: "Mark" },
                        { value: SerialPort.SpaceParity, text: "Space" }]
                }
                Label { text: "Stop Bits" }
                ComboBox {
                    id: serialStopBits
                    textRole: "text"
                    model: [{ value: SerialPort.OneStop, text: "1" },
                        { value: SerialPort.OneAndHalfStop, text: "1.5" },
                        { value: SerialPort.TwoStop, text: "2" }]
                }
                Label { text: "Stop Bits" }
                ComboBox {
                    id: serialFlowControl
                    textRole: "text"
                    model: [{ value: SerialPort.NoFlowControl, text: "None" },
                        { value: SerialPort.HardwareControl, text: "RTS/CTS" },
                        { value: SerialPort.SoftwareControl, text: "XON/XOFF" }]
                }


                Button {
                    text: "Refresh"
                    onClicked: serialManager.refreshPortInfo()
                }
            }
        }

        onOpened: serialManager.refreshPortInfo()
    }



    SerialPort {
        id: serialManager

        baudRate: serialBaud.model[serialBaud.currentIndex]
        dataBits: serialDataBits.model[serialDataBits.currentIndex]
        parity: serialParity.model[serialParity.currentIndex].value
        stopBits: serialStopBits.model[serialStopBits.currentIndex].value
        flowControl: serialFlowControl.model[serialFlowControl.currentIndex].value
        currentPort: serialPortName.currentText


        property int timer: 0

        onErrorOccurred: console.log("Error: " + serialManager.error)
        onReadyRead: readyReadSlot()
        onPlotLabelsChanged: {
            viewPort.createSeries(ChartView.SeriesTypeLine, plotLabels[plotLabels.length - 1],axisX,axisY)
        }

        onLastPointChanged: {
            var time = timer * sampleTime.realValue
            for (var i = 0; i < lastPoint.length; i++) {
                viewPort.series(i).append(time, lastPoint[i])

                if(lastPoint[i] > axisY.max)
                    axisY.max = lastPoint[i]
                else if(lastPoint[i] < axisY.min)
                    axisY.min = lastPoint[i]
            }
            if((time) > 10 && scrollPlot.checked) {
                for(i = 0; i < viewPort.count; i++) {
                    viewPort.series(i).remove(0);
                }
                axisX.min = time - 10
            }
            axisX.max = time + 1
            timer++
        }
    }

    menuBar: MenuBar {
        Menu {
            title: "Serial Coms"
            MenuItem {
                text: "Connect"
                onTriggered: serialManager.connectSerial()
                enabled: !serialManager.isConnected
                icon.source: "qrc:/images/link.png"
            }
            MenuItem {
                text: "Disconnect"
                onTriggered: serialManager.disconnectSerial()
                enabled: serialManager.isConnected
                icon.source: "qrc:/images/unlink.png"
            }
            MenuItem {
                text: "Configure"
                onTriggered: diag.open()
                enabled: !serialManager.isConnected
                icon.source: "qrc:/images/config.png"
            }
        }
    }
    footer: RowLayout {

        Button {
            Layout.margins: 5
            text: "Clear Plot"
            onClicked: {
                viewPort.removeAllSeries()
                axisX.min = 0
                axisX.max = 10
                axisY.min = 0
                axisY.max = 10

                serialManager.timer = 0
                serialManager.clearPlotLabels()
            }
            font.bold: true
        }

        Label {
            text: "Frequency"
        }
        SpinBox {
            id: sampleTime
            from: 0
            value: 100
            to: 100 * 100
            stepSize: 100
            wheelEnabled: true
            editable: true

            property int decimals: 2
            property real realValue: value / 100

            validator: DoubleValidator {
                bottom: Math.min(sampleTime.from, sampleTime.to)
                top:  Math.max(sampleTime.from, sampleTime.to)
            }
            textFromValue: function(value, locale) {
                return Number(value / 100).toLocaleString(locale, 'f', sampleTime.decimals)
            }

            valueFromText: function(text, locale) {
                return Number.fromLocaleString(locale, text) * 100
            }
            onValueModified: console.log(realValue)
        }

        CheckBox {
            id: scrollPlot
            text: "Scroll EN:"
            checked: true
        }

        Label {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignLeft
            id: statusBar
            text: serialManager.isConnected ? "Connected to port: " + serialManager.currentPort
                                            : "Disconnected"
            font.pointSize: 10
        }
    }
}
