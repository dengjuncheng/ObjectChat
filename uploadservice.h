#ifndef UPLOADSERVICE_H
#define UPLOADSERVICE_H
#include <QObject>
#include <QQueue>
class QTcpSocket;
class FileHelper;
class UploadService :public QObject
{
    Q_OBJECT
public:
    UploadService(QQueue<QString>* cache, QObject * parent = nullptr);
signals:
    void uploadSuccess(QString msg);
public slots:
    void upload();
private:
    QQueue<QString>* m_cache;
    QString m_ip;
    qint16 m_port;
    QTcpSocket* m_socket;
    FileHelper* m_fileHelper;
};

#endif // UPLOADSERVICE_H
