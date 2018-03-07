#ifndef DOWNLOADCENTER_H
#define DOWNLOADCENTER_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>

class DownLoadCenter : public QObject
{
    Q_OBJECT
public:
    DownLoadCenter(QString stuId, QObject *parent = nullptr);
    void downLoadPic(QString url);
    void connectToServer(QString fileName, QString stuId,QString currentUserId);
signals:
    void fileDownloadSuccess(QString fileName);
public slots:
    void onDownLoadPic(QNetworkReply *reply);
    void slotError(QNetworkReply::NetworkError error);
    void downloadFile(QNetworkReply *reply);
private:
    QNetworkAccessManager *m_manager;
    QString resourcePath;
    QString m_id;
    QString m_type;
    QString remoteAddress;
    QString fileName;
};

#endif // DOWNLOADCENTER_H
