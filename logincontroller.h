#ifndef LOGINCONTROLLER_H
#define LOGINCONTROLLER_H

#include <QObject>
#include <downloadcenter.h>

class ConnectionCenter;
class QTimer;
class LoginController : public QObject
{
    Q_OBJECT
public:
    explicit LoginController( ConnectionCenter *conn);

signals:
    void loginResult(QString result);
    void friendStateChanged(QString msg);
    void timeout();

public slots:
    QString getTopFiveUsers();
    void removeByStuId(QString stuId);
    void login(QString userName, QString password, QString state);
    void saveUserInfo(QString userName, QString password, QString state, bool rememberPass, QString headPic, QString nickName);
    QString getUser(){return m_user;}
    void setUser(QString user){this->m_user = user;}
    QString getFriends(){return m_friends;}
    void setFriends(QString friends){this->m_friends = friends;}
    void updateUser(QString userData);
private:
    ConnectionCenter *m_conn;
    QTimer *m_timer;
    DownLoadCenter *downLoader;
    QString m_user;
    QString m_friends;
    QString m_state; //登录状态.
};
struct UserInfo
{
    UserInfo() {}
    QString stuId;
    QString nickName;
    QString headPic;
    QString password;
    QString sex;
    QString declaration;
    QDateTime birthday;
    QString personalIntroduction;
    QDateTime lastestLogin;
    QString state;
};

#endif // LOGINCONTROLLER_H
