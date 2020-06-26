#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QUrl>

class FileIO : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(QString text READ text WRITE setText NOTIFY textChanged)

public:
    explicit FileIO(QObject *parent = nullptr);

    QUrl source();
    QString text();
    void setSource(QUrl &url);
    void setText(QString &text);

public slots:
    void read();
    void write();

signals:
    void sourceChanged();
    void textChanged();

private:
    QUrl m_source;
    QString m_text;

};

#endif // FILEIO_H
