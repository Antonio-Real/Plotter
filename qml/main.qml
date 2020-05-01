import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.12
import QtQuick.Layouts 1.12
import components.serial 1.0

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Serial Plotter")

    property alias serial: serialManager
    property alias currentPageIndex: stackId.currentIndex

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

        onErrorOccurred: console.log("Error: " + serialManager.error)
        onReadyRead: readyReadSlot()
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
        Menu {
            title: "Pages"
            MenuItem {
                text: "Chart"
                onTriggered: stackId.currentIndex = 0
            }
            MenuItem {
                text: "Console"
                onTriggered: stackId.currentIndex = 1
            }
        }
    }

    StackLayout {
        id: stackId
        anchors.fill: parent

        ChartPage { } // Index 0
        ConsolePage { } // Index 1
    }
}
