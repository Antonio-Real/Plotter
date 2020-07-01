#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickstyle>
#include <QIcon>
#include "serialport.h"
#include "fileio.h"

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);
    app.setWindowIcon(QIcon(":/images/line-chart.png"));
    app.setOrganizationName("SomeOrg");
    app.setOrganizationDomain("SomeOrg.com");

    QQuickStyle::setStyle("Fusion");
    qmlRegisterType<SerialPort>("components.serial", 1,0,"SerialPort");
    qmlRegisterType<FileIO>("components.fileio",1,0,"FileIO");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
