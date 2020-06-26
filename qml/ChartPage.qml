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
            max: 10
            labelFormat: "%d"
            labelsFont: Qt.font({pointSize: 10})
            titleText: "Units (?)"
        }
    }

    Connections {
        id: connection
        target: serialManager
        property int timer: 0

        onPlotLabelsChanged: {
            viewPort.createSeries(ChartView.SeriesTypeLine, serialManager.plotLabels[serialManager.plotLabels.length - 1],axisX,axisY)
        }
        onLastPointChanged: {
            var time = timer * sampleTime.realValue
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
            timer++
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
                axisY.max = 10

                connection.timer = 0
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
