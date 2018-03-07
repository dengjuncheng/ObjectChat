#include "uploadservice.h"
#include <QQueue>
#include <QDebug>
#include <QTcpSocket>
#include <filehelper.h>
#include <QHostAddress>

//初始化TcpSocket
UploadService::UploadService(QQueue<QString> *cache, QObject *parent): QObject(parent), m_cache(cache)
{
    m_fileHelper = new FileHelper(this);
    m_ip = "127.0.0.1";
    m_port = 8089;
    m_socket = new QTcpSocket(this);
}

//上传队列中的文件
void UploadService::upload()
{
    //上传
    if(!m_socket->isOpen())
    {
        m_socket->connectToHost(QHostAddress(m_ip), m_port);
    }
    while(m_cache->size() != 0)
    {
        QString value = m_cache->dequeue();
        QStringList values = value.split("$$");
        if(!m_socket->isOpen())
        {
            qDebug() << "未连接上上传服务器";
            m_socket->close();
            return;
        }

        QString info = values[0];
        m_socket->write(info.toUtf8());
        if(!m_socket->waitForReadyRead())
        {
            qDebug() << "上传服务器没有回传消息，断开上传";
            m_socket->close();
            return;
        }

        QString infoRes = QString(m_socket->readAll());
        if("ok" != infoRes)
        {
            qDebug() << "上传消息失败";
            m_socket->close();
        }

        QByteArray fileData = m_fileHelper->getFileByPath(values[1]);
        m_socket->write(fileData);
        if(!m_socket->waitForReadyRead())
        {
            qDebug() << "上传服务器没有回传用户消息，断开上传";
            m_socket->close();
            return;
        }
        QString result = QString(m_socket->readAll());
        emit uploadSuccess(result);
        qDebug() << "最终服务器返回的消息:" << result;
    }
    m_socket->close();
}
