#include "uploadcontroller.h"
#include <uploadservice.h>
#include <QThread>
#include <QQueue>
#include <QDebug>

//构造对象时，把该对象移动到新的线程并且开启线程
UploadController::UploadController(QObject *parent) : QObject(parent), m_cache(new QQueue<QString>)
{
    m_uploadService = new UploadService(m_cache);
    m_uploadService->moveToThread(&m_workThread);
    connect(&m_workThread, &QThread::finished, m_uploadService, &QObject::deleteLater);
    connect(this, &UploadController::startWork, m_uploadService, &UploadService::upload);
    connect(m_uploadService, &UploadService::uploadSuccess, this, &UploadController::uploadSuccess);
    m_workThread.start();
}

void UploadController::addUpload(QString info, QString filePath)
{
    QString data = info + "$$" + filePath;
    m_cache->enqueue(data);
    emit startWork();
}

UploadController::~UploadController()
{
    m_uploadService->deleteLater();
    m_workThread.quit();
    m_workThread.wait();
}
