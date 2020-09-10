import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtCharts 2.3

Page {

    signal saveValue()

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
            max: 1
            labelFormat: "%d"
            labelsFont: Qt.font({pointSize: 10})
            titleText: "Units (?)"
        }
    }

    Connections {
        id: connection
        target: serialManager
        property date initialDate

        onPlotLabelsChanged: {
            viewPort.createSeries(ChartView.SeriesTypeSpline, serialManager.plotLabels[serialManager.plotLabels.length - 1],axisX,axisY)
            initialDate = new Date()
        }
        onLastPointChanged: {
            var time = (new Date().getTime() - initialDate.getTime()) / 1000
            for (var i = 0; i < serialManager.lastPoint.length; i++) {
                viewPort.series(i).append(time, serialManager.lastPoint[i])

                if(serialManager.lastPoint[i] > axisY.max)
                    axisY.max = serialManager.lastPoint[i]
                else if(serialManager.lastPoint[i] < axisY.min)
                    axisY.min = serialManager.lastPoint[i]
            }
            if((time) > 10 && scrollPlot.checked) {
                for(i = 0; i < viewPort.count; i++) {
                    viewPort.series(i).remove(0);
                }
                axisX.min = time - 10
            }
            axisX.max = time + 1
        }
    }

    footer: RowLayout {

        Button {
            Layout.margins: 5
            text: "Clear Plot"
            font.bold: true
            onClicked: {
                axisX.min = 0
                axisX.max = 10
                axisY.min = 0
                axisY.max = 1

                serialManager.clearPlotLabels()
                viewPort.removeAllSeries()
            }
        }
        Button {
            Layout.margins: 5
            text: "Save value"
            onClicked: saveValue()
            font.bold: true
        }
        CheckBox {
            id: scrollPlot
            text: "Scrolling enabled"
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

        RowLayout {
            Layout.margins: 5
            Label { text: "Send: "  }
            TextField {
                id: txtField
                Layout.fillWidth: true
                enabled: serialManager.isConnected
                onAccepted: {
                    if(text) {
                        serialManager.data = text
                        clear()
                    }
                }
            }
        }
    }
}
