#ifndef CONNECTIONCENTER_H
#define CONNECTIONCENTER_H

#include <QObject>
#include<QWebSocket>

class ConnectionCenter : public QObject
{
    Q_OBJECT
public:
    explicit ConnectionCenter(QObject *parent = nullptr);
    void connectServer();
    void sendTextMsg(const QString &msg);
    void sendBinaryMsg(const QByteArray &data);
signals:
    void loginResult(QString msg);
    void friendStateChanged(QString msg);
    void newMsg(QString msg);
    void msgSendSuccess(QString msg);
    void msgStateChangedSuccess(QString uuid);
    void unreadMsgResult(QString msg);
    void voiceChatRequestResult(QString msg);
public slots:
    void onConnected();
    void onDestroy();
    void onTextMessageReceived(QString msg);
    void closeSocket();
    void onDisconnected();

private:
    QWebSocket *m_socket;
    QString m_url;
};

enum Code{
    LOGIN,
    FRIEND_STATE_CHANGE,
    SEND_MSG,
    NEW_MSG,
    MSG_STATE_CHANGED,
    UNREAD_MSG,
    VOICE_CHAT
};

#endif // CONNECTIONCENTER_H
