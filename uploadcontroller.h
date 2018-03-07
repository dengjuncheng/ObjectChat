#ifndef UPLOADCONTROLLER_H
#define UPLOADCONTROLLER_H

#include <QObject>
#include <QThread>
#include <QQueue>
#include <QJsonObject>

class UploadService;
class UploadController : public QObject
{
    Q_OBJECT
public:
    explicit UploadController(QObject *parent = nullptr);
    void addUpload(QString info, QString filePath);
    ~ UploadController();
signals:
    void startWork();
    void uploadSuccess(QString msg);

public slots:

private:
    QThread m_workThread;
    UploadService * m_uploadService;
    QQueue<QString> *m_cache;
};


#endif // UPLOADCONTROLLER_H
