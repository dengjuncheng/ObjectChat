#include "filehelper.h"
#include <QBuffer>
#include <QDebug>
#include <QImage>
#include <QDataStream>
#include <QPixmap>

FileHelper::FileHelper(QObject *parent) : QObject(parent)
{

}

//获取图片的二进制数组
QByteArray& FileHelper::getFileByPath(QString path)
{
    m_data.clear();
//    QString fileType = path.mid(path.lastIndexOf(".") + 1);
//    qDebug() << "文件类型:" + fileType;
//    QImage image(path);
//    QDataStream ds(&m_data, QIODevice::WriteOnly);
//    ds << image;
//    qDebug() << m_data.length();

    QPixmap pix(path);
    QBuffer buffer;
    buffer.open(QIODevice::ReadWrite);
    pix.save(&buffer,"png");
    quint32 pix_len = (quint32)buffer.data().size();
    qDebug("image size:%d",pix_len);
    m_data = buffer.data();
    return m_data;
}
