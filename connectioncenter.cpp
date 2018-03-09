#include "connectioncenter.h"
#include <QDebug>
#include <QUrl>
#include <QWebSocket>

ConnectionCenter::ConnectionCenter(QObject *parent) : QObject(parent),m_socket(new QWebSocket())
{
    m_url = "ws://localhost:8080/chat";
    connectServer();
}

//连接WebSocket的各个信号，连接到服务器
void ConnectionCenter::connectServer()
{
    connect(m_socket,&QWebSocket::connected,this,&ConnectionCenter::onConnected);
    connect(m_socket,&QWebSocket::destroyed,this,&ConnectionCenter::onDestroy);
    connect(this, &ConnectionCenter::destroyed, this , &ConnectionCenter::closeSocket);
    connect(m_socket, &QWebSocket::disconnected, this, &ConnectionCenter::onDisconnected);
    m_socket->open(QUrl(m_url));
}

//发送文本消息
void ConnectionCenter::sendTextMsg(const QString &msg)
{
    m_socket->sendTextMessage(msg);
}

//发送二进制信息，暂时没用
void ConnectionCenter::sendBinaryMsg(const QByteArray &data)
{
    m_socket->sendBinaryMessage(data);
}

//socket连接上服务器调用的方法
void ConnectionCenter::onConnected()
{
    connect(m_socket,&QWebSocket::textMessageReceived,this,&ConnectionCenter::onTextMessageReceived);
}

void ConnectionCenter::onDestroy()
{
    qDebug() << "断开连接";
}

//接收到信息时解析信息，根据信息发出不同信号
void ConnectionCenter::onTextMessageReceived(QString msg)
{
    qDebug() << "接收到信息：" << msg;
    //解析msg，然后根据返回码发送对应的信号
    msg = QString(QByteArray::fromBase64(msg.toUtf8()));
    QStringList strList = msg.split("##");
    if(strList.length() != 2){
        qDebug() << "服务器返回错误信息";
        return;
    }
    QString code = strList[0];
    switch (code.toInt()) {
    case Code::LOGIN:
        emit loginResult(strList[1]);
        break;
    case Code::FRIEND_STATE_CHANGE:
        qDebug() << "好友上线了";
        emit friendStateChanged(strList[1]);
        break;
        //这里更改好友在线状态
    case Code::SEND_MSG:
        //这里处理发送信息后的返回结果
        emit msgSendSuccess(strList[1]);
        break;
    case Code::NEW_MSG:
        emit newMsg(strList[1]);
        break;
    case Code::MSG_STATE_CHANGED:
        emit msgStateChangedSuccess(strList[1]);
        break;
    case Code::UNREAD_MSG:
        emit unreadMsgResult(strList[1]);
        break;
    case Code::VOICE_CHAT://请求语音聊天的结果
        emit voiceChatRequestResult(strList[1]);
        break;
    case Code::NEW_VOICE_CHAT_REQUEST:
        emit newVoiceChatRequest(strList[1]);
        break;
    case Code::CANLE_VOICE_CHAT:
        emit cancleVoiceChat(strList[1]);
        break;
    case Code::ACCEPT_VOICE_CHAT:
        emit startVoiceChat(strList[1]);
        break;
    case Code::REFUSE_VOICE_CHAR:
        emit voiceChatRefused(strList[1]);
        break;
    case Code::BREAK_VOICE_CHAT:
        emit breakVoiceChat(strList[1]);
        break;
    default:
        break;
    }
}

//关闭socket方法
void ConnectionCenter::closeSocket()
{
    m_socket->close();
    m_socket->deleteLater();
}

//断开连接时调用的方法
void ConnectionCenter::onDisconnected()
{
    qDebug() << "socket已经关闭,正在重连。。。。";
}
