#include "logincontroller.h"
#include <dbhelper.h>
#include <connectioncenter.h>
#include <QJsonObject>
#include <QJsonDocument>
#include <QTimer>
#include <downloadcenter.h>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDateTime>

LoginController::LoginController(ConnectionCenter *conn) :
    m_conn(conn),m_timer(new QTimer(this))
{
    m_timer->setInterval(10000);
    m_timer->setSingleShot(true);
    connect(conn,&ConnectionCenter::loginResult, this, &LoginController::loginResult);
    connect(conn,&ConnectionCenter::friendStateChanged, this, &LoginController::friendStateChanged);
    connect(m_timer, &QTimer::timeout, this, &LoginController::timeout);
}

QString LoginController::getTopFiveUsers()
{
    return DbHelper::getInstance()->getTopFiveUser();
}

void LoginController::removeByStuId(QString stuId)
{
    DbHelper::getInstance()->deleteByStuId(stuId);
}

//登录方法
void LoginController::login(QString userName, QString password, QString state)
{
    QJsonObject obj;
    QJsonDocument doc;
    obj.insert("userName", userName);
    obj.insert("password",password);
    obj.insert("state", state);
    m_state = state; //把登录的状态记录下来
    doc.setObject(obj);
    QString data(doc.toJson(QJsonDocument::Compact));
    QString msg = QString("%1##%2").arg(QString::number(Code::LOGIN)).arg(data);
    m_conn->sendTextMsg(msg.toUtf8().toBase64());
    m_timer->start();
}

//数据库操作
void LoginController::saveUserInfo(QString userName, QString password,QString state, bool rememberPass, QString headPic, QString nickName)
{
//    downLoader = new DownLoadCenter(userName,this);
//    downLoader->downLoadPic(headPic);
    DbHelper::getInstance()->saveUser(userName, password, state, rememberPass?1:0,headPic,nickName);
}


//更新用户状态
void LoginController::updateUser(QString userData)
{
    qDebug() << userData;
    QJsonDocument document = QJsonDocument::fromJson(userData.toUtf8());
    QJsonObject jsonObject = document.object();
    UserInfo userInfo;
    userInfo.stuId = jsonObject.take("stuId").toString();
    userInfo.nickName = jsonObject.take("nickName").toString();
    userInfo.password = jsonObject.take("password").toString();
    userInfo.headPic = jsonObject.take("headPic").toString();
    userInfo.sex = jsonObject.take("sex").toString();
    userInfo.declaration = jsonObject.take("declaration").toString();
    userInfo.birthday = QDateTime::fromTime_t(static_cast<long>(jsonObject.take("birthday").toDouble())/1000);
    userInfo.personalIntroduction = jsonObject.take("personalIntroduction").toString();
    userInfo.lastestLogin = QDateTime::fromTime_t(static_cast<long>(jsonObject.take("lastestLogin").toDouble())/1000);
    userInfo.state = m_state;
    DbHelper::getInstance()->updateUser(userInfo);
}

