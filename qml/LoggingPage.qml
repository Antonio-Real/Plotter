import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Qt.labs.platform 1.1
import components.fileio 1.0

Page {

    property string str

    onStrChanged: txtEdit.append(str + "\n");

    ColumnLayout {
        anchors.fill: parent

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.margins: 5
            border.color: "black"

            Flickable {
                anchors.fill: parent
                boundsBehavior: Flickable.OvershootBounds
                TextArea.flickable: TextArea {
                    id: txtEdit
                    readOnly: true
                    selectByMouse: true
                    color: "black"
                }
                ScrollBar.vertical: ScrollBar{ }
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
        Button {
            Layout.margins: 5
            font.bold: true
            text: "Export"
            onClicked: fileDiag.open()
        }

        Item { Layout.fillWidth: true }
    }

    FileIO {
        id: fileIO
    }

    FileDialog {
        id: fileDiag
        modality: Qt.WindowModal
        nameFilters: ["Excel (*.csv)","Text (*.txt)"]
        fileMode: FileDialog.SaveFile

        onAccepted: {
            fileIO.source = file;
            fileIO.text = txtEdit.text
            fileIO.write()
        }

    }
}
