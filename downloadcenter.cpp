#include "downloadcenter.h"
#include <QNetworkAccessManager>
#include <QUrl>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QPixmap>
#include <QFile>
#include <QDir>
#include <QCoreApplication>
#include <QDebug>
#include <QNetworkAccessManager>

DownLoadCenter::DownLoadCenter(QString stuId,QObject *parent):QObject(parent),m_manager(new QNetworkAccessManager(this))
{
    remoteAddress = "http://localhost:8080";
    QString basePath = QCoreApplication::applicationDirPath();
    m_id = stuId;
    basePath = basePath + "/resources/" + stuId;
    QDir dir(basePath);
    if(!dir.exists())
    {
        dir.mkpath(basePath);
    }
    resourcePath = basePath;
}

void DownLoadCenter::downLoadPic(QString url)
{
    connect(m_manager, &QNetworkAccessManager::finished, this, &DownLoadCenter::onDownLoadPic);
    qDebug() << url;
    m_type = url.split(".").last();
    QNetworkRequest request;
    request.setUrl(QUrl(url));
    request.setRawHeader("User-Agent", "MyOwnBrowser 1.0");
    QNetworkReply *reply = m_manager->get(request);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(slotError(QNetworkReply::NetworkError)));
}

void DownLoadCenter::connectToServer(QString fileName, QString stuId, QString currentUserId)
{
    this->fileName = fileName;
    this->m_id = currentUserId;
    connect(m_manager, &QNetworkAccessManager::finished, this, &DownLoadCenter::downloadFile);
    QNetworkRequest request;
    request.setUrl(QUrl(remoteAddress + "/temp/" + stuId + "/" + fileName));
    request.setRawHeader("User-Agent", "MyOwnBrowser 1.0");
    QNetworkReply *reply = m_manager->get(request);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)),
            this, SLOT(slotError(QNetworkReply::NetworkError)));
}

void DownLoadCenter::onDownLoadPic(QNetworkReply *reply)
{
    qDebug() << "收到回复";
    QDir dir(resourcePath + "/picture");
    if(!dir.exists()){
        dir.mkpath(resourcePath + "/picture");
    }
    QString filePath = resourcePath + "/picture" +"/head." + m_type;
    if(reply->error() == QNetworkReply::NoError)
    {
       QByteArray bytes = reply->readAll();
       QFile file(filePath);

       if(!file.exists())
       {

       }

       if (file.open(QIODevice::WriteOnly))
       {
           file.write(bytes);
       }
       file.close();
    }
    disconnect(m_manager, &QNetworkAccessManager::finished, this, &DownLoadCenter::onDownLoadPic);
    reply->deleteLater();
}

void DownLoadCenter::slotError(QNetworkReply::NetworkError error)
{
    qDebug() << error;
    QNetworkReply *reply =(QNetworkReply *) sender();
    reply->deleteLater();
}

void DownLoadCenter::downloadFile(QNetworkReply *reply)
{
    QString path = QCoreApplication::applicationDirPath() + "/resources/" + m_id + "/file/";
    QDir dir(path);
    if(!dir.exists()){
        dir.mkpath(path);
    }
    QString filePath = path + fileName;
    if(reply->error() == QNetworkReply::NoError)
    {
       QByteArray bytes = reply->readAll();
       QFile file(filePath);

       if(!file.exists())
       {

       }

       if (file.open(QIODevice::WriteOnly))
       {
           file.write(bytes);
       }
       file.close();
    }
    disconnect(m_manager, &QNetworkAccessManager::finished, this, &DownLoadCenter::downloadFile);
    emit fileDownloadSuccess(path);
    reply->deleteLater();
}

