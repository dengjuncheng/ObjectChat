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
    case Code::LOGIN:                      // 登录结果
        emit loginResult(strList[1]);
        break;
    case Code::FRIEND_STATE_CHANGE:        //好友在线状态变更， 暂时弃用状态
        qDebug() << "好友上线了";
        emit friendStateChanged(strList[1]);
        break;
        //这里更改好友在线状态
    case Code::SEND_MSG:                   //发送新的消息后的返回信息
        //这里处理发送信息后的返回结果
        emit msgSendSuccess(strList[1]);
        break;
    case Code::NEW_MSG:                    //有新的消息
        emit newMsg(strList[1]);
        break;
    case Code::MSG_STATE_CHANGED:          //聊天记录状态更新
        emit msgStateChangedSuccess(strList[1]);
        break;
    case Code::UNREAD_MSG:                 //获取未读信息
        emit unreadMsgResult(strList[1]);
        break;
    case Code::VOICE_CHAT:                 //请求语音聊天的结果
        emit voiceChatRequestResult(strList[1]);
        break;
    case Code::NEW_VOICE_CHAT_REQUEST:      //有新的语音聊天请求
        emit newVoiceChatRequest(strList[1]);
        break;
    case Code::CANLE_VOICE_CHAT:            //请求方取消语音聊天
        emit cancleVoiceChat(strList[1]);
        break;
    case Code::ACCEPT_VOICE_CHAT:           //接受语音聊天
        emit startVoiceChat(strList[1]);
        break;
    case Code::REFUSE_VOICE_CHAT:           //拒绝语音聊天
        emit voiceChatRefused(strList[1]);
        break;
    case Code::BREAK_VOICE_CHAT:            //断开语音聊天
        emit breakVoiceChat(strList[1]);
        break;
    case Code::SEARCH_USER:                 //用户查询
        emit searchUserResult(strList[1]);
        break;
    case Code::ADD_FRIEND:                  //添加好友请求
        emit addFriendResult(strList[1]);
        break;
    case Code::ALL_ADD_REQUEST:             //获取前20个好友请求
        emit allAddRequest(strList[1]);
        break;
    case Code::MODIFY_ADD_REQUEST_STATE:   //修改添加好友的状态结果
        emit modifyAddRequestStateResult(strList[1]);
        break;
    case Code::NEW_FRIEND:                 //新的好友
        emit newFriend(strList[1]);
        break;
    case Code::NEW_ADD_REQUEST:            //新的添加好友请求
        emit newAddRequest(strList[1]);
        break;
    case Code::UPDATE_USER_INFO:
        emit updateUserInfoResult(strList[1]); //更新用户信息结果
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
