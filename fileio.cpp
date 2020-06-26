#include "fileio.h"
#include <QFile>
#include <QTextStream>
#include <QIODevice>
#include <QDebug>

FileIO::FileIO(QObject *parent) : QObject(parent)
{

}

QUrl FileIO::source()
{
    return m_source;
}

QString FileIO::text()
{
    return m_text;
}

void FileIO::setSource(QUrl &url)
{
    m_source = url;
    emit sourceChanged();
}

void FileIO::setText(QString &text)
{
    m_text = text;
    emit textChanged();
}

void FileIO::read()
{
    if(m_source.isEmpty()) {
        return;
    }
    QFile file(m_source.toLocalFile());
    if(!file.exists()) {
        qWarning() << "Does not exits: " << m_source.toLocalFile();
        return;
    }
    if(file.open(QIODevice::ReadOnly)) {
        QTextStream stream(&file);
        m_text = stream.readAll();
        emit textChanged();
    }
}

void FileIO::write()
{
    if(m_source.isEmpty()) {
        return;
    }
    QFile file(m_source.toLocalFile());
    if(file.open(QIODevice::WriteOnly)) {
        QTextStream stream(&file);
        stream << m_text;
    }
}
