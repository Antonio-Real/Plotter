import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {

    Connections {
        target: serialManager
        onDataChanged: {
            if(currentPageIndex == 1)
                txtEdit.append("IN   >>> " + serialManager.data)
        }
    }

    ColumnLayout {
        anchors.fill: parent
        RowLayout {
            Layout.margins: 5
            Layout.bottomMargin: 0
            Label { text: "Send: "  }
            TextField {
                id: txtField
                Layout.fillWidth: true
                enabled: serialManager.isConnected
                onAccepted: {
                    if(text) {
                        txtEdit.append("OUT <<< " + text)
                        serialManager.data = text + '\r'
                        clear()
                    }
                }
            }
        }
        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 5
            border.color: "black"

            Flickable {
                anchors.fill: parent
                TextArea.flickable: TextArea {
                    id: txtEdit
                    enabled: false
                    color: "black"
                }
            }
        }
    }

    footer: RowLayout {
        Button {
            Layout.margins: 5
            font.bold: true
            text: "Clear"
            onClicked: txtEdit.clear()
        }
        Item { Layout.fillWidth: true }
    }
}
