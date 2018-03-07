#include "messagecontroller.h"
#include <connectioncenter.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>
#include <dbhelper.h>
#include <QDebug>
#include <QJsonArray>

MessageController::MessageController(ConnectionCenter *conn, QObject *parent) :
    QObject(parent),m_conn(conn)
{
}

/**
 * @brief MessageController::onNewMsg
 * @param msg
 * 接收方接收到新的信息，存储在数据库里
 */
void MessageController::onNewMsg(QString msg)
{
    QJsonDocument document = QJsonDocument::fromJson(msg.toUtf8());
    QJsonObject jsonObject = document.object();
    MsgInfo msgInfo;
    msgInfo.userId = jsonObject.take("userId").toString();
    msgInfo.friendId = jsonObject.take("friendId").toString();
    msgInfo.msg = jsonObject.take("msg").toString();
    msgInfo.msgType = jsonObject.take("msgType").toInt(0);
    msgInfo.direction = false;
    msgInfo.sendTime = QDateTime::currentDateTime();
    msgInfo.uuid = jsonObject.take("uuid").toString();
    bool result = DbHelper::getInstance()->insertNewMsg(msgInfo);
    if(result)
        emit newMsg(msg);
    qDebug() << "MessageController::onNewMsg:" << "接收到新的消息，uuid(" << msgInfo.uuid << ")";
}
/**
 * @brief MessageController::onMsgSendSuccess
 * @param msg
 * 发送信息成功后返回的数据需要存储在数据库里，相对于发送方
 */
void MessageController::onMsgSendSuccess(QString msg)
{
    qDebug() << "MessageController::onMsgSendSuccess:" << "发送的消息已经存储在服务器上";
    QJsonDocument document =  QJsonDocument::fromJson(msg.toUtf8());
    QJsonObject jsonObject = document.object();
    int resultCode = jsonObject.take("code").toInt(-1);
    if(resultCode == 0)
    {
        QJsonObject valueObject = jsonObject.take("msgInfo").toObject();
        MsgInfo msgInfo;
        msgInfo.userId = valueObject.take("userId").toString();
        msgInfo.friendId = valueObject.take("friendId").toString();
        msgInfo.msg = valueObject.take("msg").toString();
        msgInfo.msgType = valueObject.take("msgType").toInt(0);
        msgInfo.direction = true;
        msgInfo.sendTime = QDateTime::currentDateTime();
        msgInfo.uuid = valueObject.take("uuid").toString();
        DbHelper::getInstance()->insertNewMsg(msgInfo);
    }
}

//接收到未读信息时
void MessageController::onUnreadMsgResult(QString msg)
{
    QJsonDocument document = QJsonDocument::fromJson(msg.toUtf8());
    QJsonObject jsonObject = document.object();
    int resultCode = jsonObject.take("code").toInt(-1);
    if(resultCode == 0)
    {
        QJsonArray jsonArray = jsonObject.take("msgInfo").toArray();
        int size = jsonArray.size();
        for(int i = 0; i < size ; ++i)
        {
            QJsonObject temp = jsonArray[i].toObject();
            MsgInfo info;
            info.userId = temp.value("userId").toString();
            info.friendId = temp.value("friendId").toString();
            info.msg = temp.value("msg").toString();
            info.msgType = temp.value("msgType").toInt(0);
            info.direction = false;
            info.uuid = temp.value("uuid").toString();
            info.sendTime = QDateTime::fromTime_t(temp.take("sendTime").toInt(0));
            bool result = DbHelper::getInstance()->insertNewMsg(info);
            //判断数据库中是否已经保存了未读信息
            if(result)
            {
                QJsonDocument jDocument;
                jDocument.setObject(temp);
                emit newMsg(QString(jDocument.toJson()));
            }
        }
    }
}
