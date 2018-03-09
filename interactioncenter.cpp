#include "interactioncenter.h"
#include <dbhelper.h>
#include <QDateTime>
#include <capturescreen.h>
#include <QDebug>
#include <QDomDocument>
#include <filehelper.h>
#include <connectioncenter.h>
#include <QJsonObject>
#include <QJsonDocument>
#include <QUuid>
#include <uploadcontroller.h>
#include <messagecontroller.h>
#include <voicechatcontroller.h>

//连接各个组件之间信号和槽
InteractionCenter::InteractionCenter(CaptureScreen *obj, FileHelper* obj2, ConnectionCenter *conn, QObject *parent) : QObject(parent),
    captureScreen(obj),fileHelper(obj2),m_conn(conn),
    m_uploadController(new UploadController(this)),
    m_messageController(new MessageController(conn,this)),
    m_voiceChatController(new VoiceChatController(this))
{
    connect(captureScreen,&CaptureScreen::signalCompleteCature, this, &InteractionCenter::signalCompleteCature);
    connect(m_uploadController, &UploadController::uploadSuccess, this, &InteractionCenter::sendTextMsg);
    connect(conn,&ConnectionCenter::newMsg,m_messageController, &MessageController::onNewMsg);
    //connect(conn,&ConnectionCenter::newMsg,this,&InteractionCenter::newMsg);
    connect(conn,&ConnectionCenter::msgSendSuccess,m_messageController,&MessageController::onMsgSendSuccess);
    connect(conn,&ConnectionCenter::msgStateChangedSuccess,this, &InteractionCenter::updateMsgState);
    connect(conn,&ConnectionCenter::unreadMsgResult,m_messageController,&MessageController::onUnreadMsgResult);
    connect(m_messageController,&MessageController::newMsg,this,&InteractionCenter::newMsg);

    //语音聊天信号槽连接
    connect(conn,&ConnectionCenter::voiceChatRequestResult, this, &InteractionCenter::voiceChatRequestResult);
    connect(conn,&ConnectionCenter::newVoiceChatRequest, this, &InteractionCenter::newVoiceChatRequest);
    connect(conn,&ConnectionCenter::cancleVoiceChat, this,&InteractionCenter::cancleVoiceChat);
    connect(conn,&ConnectionCenter::startVoiceChat,this,&InteractionCenter::startVoiceChat);

    //连接到语音传输线程，开始通过目标ip传输语音消息 ,因为需要异步使用音频消息，所以需要使用信号槽连接
    connect(this,&InteractionCenter::startAsynVoiceChat, m_voiceChatController, &VoiceChatController::startVoiceChat);
    connect(conn, &ConnectionCenter::voiceChatRefused, this, &InteractionCenter::voiceChatRefused);
    connect(conn, &ConnectionCenter::breakVoiceChat, this, &InteractionCenter::voiceChatBreak); //改变界面数据
    connect(conn,&ConnectionCenter::breakVoiceChat,m_voiceChatController,&VoiceChatController::interrupt); //修改另一个线程中的语音通信
}

InteractionCenter::~InteractionCenter()
{
    captureScreen->deleteLater();
}

//数据库操作
void InteractionCenter::addContact(QString userId, QString friendId)
{
    DbHelper::getInstance()->insertContact(userId, friendId);
}

//数据库操作
QString InteractionCenter::getContactByUserId(QString userId)
{
    return DbHelper::getInstance()->getContactByUserId(userId);
}

//数据库操作
void InteractionCenter::updateContactAddTime(QString userId, QString friendId)
{
    DbHelper::getInstance()->updateContactAddTime(userId, friendId);
}

//数据库操作
QString InteractionCenter::getCurrentDateTime(QString format)
{
    return QDateTime::currentDateTime().toString(format);
}

//截图操作
void InteractionCenter::capture()
{
    captureScreen->captureScreen();
}

//数据库操作
QString InteractionCenter::getChatRecordByUserId(QString userId, QString friendId)
{
    return DbHelper::getInstance()->getChatRecordByUserId(userId, friendId);
}

//数据库操作
void InteractionCenter::updateReadMsg(QString userId, QString friendId)
{
    DbHelper::getInstance()->updateReadMsg(userId, friendId);
}

//数据库操作
QString InteractionCenter::getLastMsg(QString userId, QString friendId)
{
    return DbHelper::getInstance()->getLastMsg(userId, friendId);
}

//根据时间戳和字符串格式获取时间的字符串类型
QString InteractionCenter::getDateString(int timestamp, QString format)
{
    QDateTime dateTime = QDateTime::fromTime_t(timestamp);
    return dateTime.toString(format);
}

/**
 * @brief InteractionCenter::sendMsg
 * @param userId   发送方的id
 * @param friendId   接受方的id
 * @param msg      整个富文本内容，用来获取图片信息
 * @param text    纯文本内容
 */
void InteractionCenter::sendMsg(QString userId, QString friendId, QString msg, QString text)
{
    QDomDocument doc;
    if(!doc.setContent(msg))
    {
        qDebug() << "dom对象建立失败";
        return;
    }
    QDomElement root = doc.documentElement();
    QDomNodeList list = root.elementsByTagName("img");
    int size = list.size();
    QList<QString> picPathList;
    //获取富文本信息里的图片路径
    for(int i = 0; i < size; ++i){
        picPathList.append(list.at(i).toElement().attribute("src"));
    }
    //对每张图片进行上传
    foreach (QString item, picPathList) {
        //构造请求内容
        QJsonObject jsonObj;
        QJsonDocument document;
        jsonObj.insert("userId", userId);
        jsonObj.insert("friendId", friendId);
        QString fileName = QUuid::createUuid().toString();
        fileName.remove("{").remove("}").remove("-");
        jsonObj.insert("fileName", fileName + item.mid(item.lastIndexOf(".")));
        jsonObj.insert("filePath", item);
        jsonObj.insert("msgType",TYPE_PNG);
        jsonObj.insert("uuid", fileName);
        jsonObj.insert("direction", true);
        document.setObject(jsonObj);
        m_uploadController->addUpload(QString(document.toJson()), item);
    }
    text.replace(QChar(65532), "");  //这里有一个unicode值为 65532的看不见的空白字符，需要替换掉。
    //发送文本内容
    if(text.trimmed() != "")
    {
        QJsonObject jsonObj;
        QJsonDocument document;
        jsonObj.insert("userId", userId);
        jsonObj.insert("friendId", friendId);
        jsonObj.insert("msgType", TYPE_TEXT);
        QString uuid = QUuid::createUuid().toString();
        uuid.remove("{").remove("}").remove("-");
        jsonObj.insert("uuid", uuid);
        jsonObj.insert("msg", text.trimmed());
        jsonObj.insert("direction", true);
        document.setObject(jsonObj);

        QString data(document.toJson());
        sendTextMsg(data);
    }
}

//当信息的状态改变时，执行此方法，发送给服务器
void InteractionCenter::msgStateChanged(QString uuid)
{
    //发送到服务器，告诉服务器某条信息已经被阅读
    QString msg = QString("%1##%2").arg(QString::number(Code::MSG_STATE_CHANGED)).arg(uuid);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
}

//发送文本信息
void InteractionCenter::sendTextMsg(QString msg)
{
    emit msgHasBeenSent(msg);
    qDebug() << "发送文本信息:" << msg;
    msg = QString("%1##%2").arg(QString::number(Code::SEND_MSG)).arg(msg);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
}

void InteractionCenter::updateMsgState(QString uuid)
{
    //修改本地数据库的状态
    DbHelper::getInstance()->updateMsgState(uuid);
}

//发送信息给服务器，检查是否有未读信息
void InteractionCenter::getUnreadMsg(QString stuId)
{
    QString msg = QString("%1##%2").arg(QString::number(Code::UNREAD_MSG)).arg(stuId);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
}

int InteractionCenter::getUnreadCount(QString userId, QString friendId)
{
    return DbHelper::getInstance()->getUnreadCount(userId, friendId);
}

void InteractionCenter::voiceChatRequest(QString userId, QString friendId)
{
    emit m_voiceChatController->startVoiceChat("127.0.0.1");
}

void InteractionCenter::readyVoiceChat(QString userId, QString friendId)
{
    QJsonDocument document;
    QJsonObject  jsonObj;
    jsonObj.insert("userId", userId);
    jsonObj.insert("friendId", friendId);
    document.setObject(jsonObj);
    QString data(QString(document.toJson()));
    QString msg = QString("%1##%2").arg(QString::number(Code::VOICE_CHAT)).arg(data);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
}

void InteractionCenter::cancleVoiceRequest(QString userId, QString friendId)
{
    QJsonDocument document;
    QJsonObject  jsonObj;
    jsonObj.insert("userId", userId);
    jsonObj.insert("friendId", friendId);
    document.setObject(jsonObj);
    QString data(QString(document.toJson()));
    QString msg = QString("%1##%2").arg(QString::number(Code::CANLE_VOICE_CHAT)).arg(data);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
}

void InteractionCenter::accepteVoiceRequest(QString userId, QString friendId)
{
    QJsonDocument document;
    QJsonObject  jsonObj;
    jsonObj.insert("userId", userId);
    jsonObj.insert("friendId", friendId);
    document.setObject(jsonObj);
    QString data(QString(document.toJson()));
    QString msg = QString("%1##%2").arg(QString::number(Code::ACCEPT_VOICE_CHAT)).arg(data);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
}

void InteractionCenter::onStartVoiceChat(QString targetIp)
{
    emit startAsynVoiceChat(targetIp);
}

void InteractionCenter::refuseVoiceChat(QString userId, QString friendId)
{
    QJsonDocument document;
    QJsonObject  jsonObj;
    jsonObj.insert("userId", userId);
    jsonObj.insert("friendId", friendId);
    document.setObject(jsonObj);
    QString data(QString(document.toJson()));
    QString msg = QString("%1##%2").arg(QString::number(Code::REFUSE_VOICE_CHAT)).arg(data);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
}

void InteractionCenter::breakVoiceChat(QString userId, QString friendId)
{
    QJsonDocument document;
    QJsonObject  jsonObj;
    jsonObj.insert("userId", userId);
    jsonObj.insert("friendId", friendId);
    document.setObject(jsonObj);
    QString data(QString(document.toJson()));
    QString msg = QString("%1##%2").arg(QString::number(Code::BREAK_VOICE_CHAT)).arg(data);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
    m_voiceChatController->interrupt(); //发起断开方 终止udp输出和音频录入
}
