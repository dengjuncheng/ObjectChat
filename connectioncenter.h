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
    void newVoiceChatRequest(QString msg);
    void cancleVoiceChat(QString msg);
    void startVoiceChat(QString msg);
    void voiceChatRefused(QString msg);
    void breakVoiceChat(QString msg);
    void searchUserResult(QString msg);
    void addFriendResult(QString msg);
    void allAddRequest(QString msg);
    void modifyAddRequestStateResult(QString msg);
    void newFriend(QString msg);
    void newAddRequest(QString msg);
    void updateUserInfoResult(QString msg);
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
    VOICE_CHAT,
    NEW_VOICE_CHAT_REQUEST,
    CANLE_VOICE_CHAT,
    ACCEPT_VOICE_CHAT,
    REFUSE_VOICE_CHAT,
    BREAK_VOICE_CHAT,
    SEARCH_USER,
    ADD_FRIEND,
    NEW_ADD_REQUEST,
    ALL_ADD_REQUEST,
    MODIFY_ADD_REQUEST_STATE,
    NEW_FRIEND,
    UPDATE_USER_INFO
};

#endif // CONNECTIONCENTER_H
