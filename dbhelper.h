#ifndef DBHELPER_H
#define DBHELPER_H

#include <QObject>

struct UserInfo;
struct MsgInfo;
class DbHelper : public QObject
{
    Q_OBJECT
public:
    explicit DbHelper(QObject *parent = nullptr);
    static DbHelper *getInstance();
    QString test();
    QString getTopFiveUser();
    void deleteByStuId(QString stuId);
    void saveUser(QString userName, QString password, QString state, int remeberPass, QString headPic, QString nickName);
    void updateLastTimeByStuId(QString stuId);
    void insert(QString userName, QString password, QString state, int remeberPass, QString headPic, QString nickName);
    void insertContact(QString userId, QString friendId);
    QString getContactByUserId(QString userId);
    void updateContactAddTime(QString userId, QString friendId);
    QString getChatRecordByUserId(QString userId, QString friendId);
    void updateReadMsg(QString userId, QString friendId);
    QString getLastMsg(QString userId, QString friendId);
    void updateUser(UserInfo userInfo);
    bool insertNewMsg(MsgInfo msgInfo);
    void updateMsgState(QString uuid);
    bool isReceivedMsg(QString uuid);
    int getUnreadCount(QString userId, QString friendId);
signals:

public slots:
};

#endif // DBHELPER_H
