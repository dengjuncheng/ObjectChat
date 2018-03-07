#include "dbhelper.h"
#include <QSqlDatabase>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QDateTime>
#include <logincontroller.h>
#include <messagecontroller.h>

DbHelper::DbHelper(QObject *parent) : QObject(parent)
{
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName("./db/chat.db");
    if(!db.open())
    {
        qDebug() << "数据库链接失败";
        return;
    }
}

//单例数据库操作对象
DbHelper* DbHelper::getInstance()
{
    static DbHelper db;
    return &db;
}

QString DbHelper::test()
{
    QSqlQuery query;
    //qDebug() << query.exec("SELECT * FROM user");
    if( !query.exec("SELECT * FROM user") )
    {
        qDebug() << query.lastError().text();
    }
    query.next();
    QString name = query.value("nickname").toString();
    qDebug() << name;
    return "";
}

//获得最近登录过的前5位信息
QString DbHelper::getTopFiveUser()
{
    QSqlQuery query;
    if(!query.exec("select stu_id,nickname,password,head_pic,remenberPass,state from user order by last_login desc limit 5"))
    {
        qDebug() << query.lastError().text();
    }
    QJsonDocument document;
    QJsonArray array;
    while(query.next()){
        QJsonObject jsonObj;
        jsonObj.insert("stuId", query.value("stu_id").toString());
        jsonObj.insert("nickName",query.value("nickname").toString());
        jsonObj.insert("password", query.value("password").toString());
        jsonObj.insert("headPic",query.value("head_pic").toString());
        jsonObj.insert("remenberPass", query.value("remenberPass").toInt());
        jsonObj.insert("state", query.value("state").toString());
        array.append(jsonObj);
    }
    document.setArray(array);
    QString reString = QString(document.toJson());
    return reString   ;
}

//删除登陆过的用户信息
void DbHelper::deleteByStuId(QString stuId)
{
    QSqlQuery query;
    query.prepare("delete from user where stu_id = ?");
    query.addBindValue(stuId);
    query.exec();
}

//登录用户后保存到数据库
void DbHelper::saveUser(QString userName, QString password, QString state, int remeberPass, QString headPic, QString nickName)
{
    QSqlQuery query;
    query.prepare("delete from user where stu_id=?");
    query.addBindValue(userName);
    query.exec();
    insert(userName,password,state,remeberPass,headPic,nickName);
}

//如果用户以前登陆过，则更新最近登录时间
void DbHelper::updateLastTimeByStuId(QString stuId)
{
    QSqlQuery query;
    query.prepare("update user set last_login=? where stu_id=?");
    query.addBindValue(QDateTime::currentDateTime());
    query.addBindValue(stuId);
    query.exec();
}


void DbHelper::insert(QString userName, QString password, QString state, int remeberPass, QString headPic, QString nickName)
{
    QSqlQuery query;
    query.prepare("insert into user (stu_id,nickname,password,head_pic,remenberPass,state,last_login) values (?,?,?,?,?,?,?)");
    query.addBindValue(userName);
    query.addBindValue(nickName);
    query.addBindValue(password);
    query.addBindValue(headPic);
    query.addBindValue(remeberPass);
    query.addBindValue(state);
    query.addBindValue(QDateTime::currentDateTime());
    query.exec();
    qDebug() << query.lastError().text();
}

//添加最近联系人到数据库
void DbHelper::insertContact(QString userId, QString friendId)
{
    QSqlQuery query;
    query.prepare("insert into contact (stu_id,friend_id,add_time) values(?,?,?)");
    query.addBindValue(userId);
    query.addBindValue(friendId);
    query.addBindValue(QDateTime::currentDateTime());
    query.exec();
    qDebug() << query.lastError().text();
}

//通过用户id获取最近联系人
QString DbHelper::getContactByUserId(QString userId)
{
    QSqlQuery query;
    query.prepare("select stu_id,friend_id,add_time from contact where stu_id=? order by add_time desc");
    query.addBindValue(userId);
    query.exec();
    QJsonDocument document;
    QJsonArray array;
    while(query.next()){
        QJsonObject jsonObject;
        jsonObject.insert("stuId",query.value("friend_id").toString());
        jsonObject.insert("addTime", query.value("add_time").toDateTime().toString("yy-MM-dd"));
        array.append(jsonObject);
    }
    document.setArray(array);
    return QString(document.toJson());
}

//更新最近联系人添加时间
void DbHelper::updateContactAddTime(QString userId, QString friendId)
{
    QSqlQuery query;
    query.prepare("update contact set add_time=? where stu_id=? and friend_id=?");
    query.addBindValue(QDateTime::currentDateTime());
    query.addBindValue(userId);
    query.addBindValue(friendId);
    query.exec();
    qDebug() << query.lastError().text();
}

//获取与某位好友的聊天记录
QString DbHelper::getChatRecordByUserId(QString userId, QString friendId)
{
    QSqlQuery query;
    query.prepare("select user_id, friend_id, msg, direction, add_time,is_read, uuid, msg_type from chat_record where user_id = ? and friend_id = ? order by add_time asc");
    query.addBindValue(userId);
    query.addBindValue(friendId);
    query.exec();
    QJsonDocument document;
    QJsonArray array;
    while(query.next())
    {
        QJsonObject jsonObject;
        jsonObject.insert("userId", query.value("user_id").toString());
        jsonObject.insert("friendId", query.value("friend_id").toString());
        jsonObject.insert(("msg"), query.value("msg").toString());
        jsonObject.insert(("direction"), query.value("direction").toBool());
        jsonObject.insert("addTime", query.value("add_time").toDateTime().toString("yy-MM-dd hh:mm:ss"));
        jsonObject.insert("isRead", query.value("is_read").toBool());
        jsonObject.insert("uuid", query.value("uuid").toString());
        jsonObject.insert("msgType", query.value("msg_type").toInt());
        array.append(jsonObject);
    }
    document.setArray(array);
    return QString(document.toJson());
}

//更新信息阅读状态
void DbHelper::updateReadMsg(QString userId, QString friendId)
{
    QSqlQuery query;
    query.prepare("update chat_record set is_read=true where user_id = ? and friend_id = ?");
    query.addBindValue(userId);
    query.addBindValue(friendId);
    query.exec();
    qDebug() << query.lastError().text();
}

//获取最后一条信息
QString DbHelper::getLastMsg(QString userId, QString friendId)
{
    QSqlQuery query;
    query.prepare("select msg,msg_type from chat_record where user_id = ? and friend_id = ? order by add_time desc limit 1");
    query.addBindValue(userId);
    query.addBindValue(friendId);
    query.exec();
    QJsonDocument document;
    QJsonObject jsonObject;
    if(query.next()){
        jsonObject.insert("lastMsg",query.value("msg").toString());
        jsonObject.insert("msgType", query.value("msg_type").toInt());
        document.setObject(jsonObject);
        return QString(document.toJson());
    }
    document.setObject(jsonObject);
    qDebug() << "DbHelper::getLastMsg:"<< query.lastError().text();
    return QString(document.toJson());
}

//更新用户信息
void DbHelper::updateUser(UserInfo userInfo)
{
    QSqlQuery query;
    query.prepare("update user set nickname=?, password=?,head_pic=?,sex=?,declaration=?,birthday=?,personal_introduction=?,last_login=?,state=? where stu_id=?");
    query.addBindValue(userInfo.nickName);;
    query.addBindValue(userInfo.password);
    query.addBindValue(userInfo.headPic);
    query.addBindValue(userInfo.sex);
    query.addBindValue(userInfo.declaration);
    query.addBindValue(userInfo.birthday);
    query.addBindValue(userInfo.personalIntroduction);
    query.addBindValue(userInfo.lastestLogin);
    query.addBindValue(userInfo.state);
    query.addBindValue(userInfo.stuId);
    query.exec();
    qDebug()<<query.lastError().text();
}

//从服务器获取未读信息插入到本地数据库
bool DbHelper::insertNewMsg(MsgInfo msgInfo)
{
    if(isReceivedMsg(msgInfo.uuid))
    {
        return false;
    }
    QSqlQuery query;
    query.prepare("insert into chat_record (user_id,msg,friend_id,msg_type,uuid,file_path,file_name,direction,add_time,is_read) values(?,?,?,?,?,?,?,?,?,?)");
    query.addBindValue(msgInfo.userId);
    query.addBindValue(msgInfo.msg);
    query.addBindValue(msgInfo.friendId);
    query.addBindValue(msgInfo.msgType);
    query.addBindValue(msgInfo.uuid);
    query.addBindValue(msgInfo.filePath);
    query.addBindValue(msgInfo.fileName);
    query.addBindValue(msgInfo.direction);
    query.addBindValue(msgInfo.sendTime);
    query.addBindValue(false);
    query.exec();
    qDebug() << query.lastError().text();
    return true;
}

//通过信息的uuid更新信息的状态
void DbHelper::updateMsgState(QString uuid)
{
    QSqlQuery query;
    query.prepare("update chat_record set is_read = 1 where uuid = ?");
    query.addBindValue(uuid);
    query.exec();
    qDebug() << query.lastError().text();
}

//判断服务器上的未读信息是否已经添加到本地数据库
bool DbHelper::isReceivedMsg(QString uuid)
{
    QSqlQuery query;
    query.prepare("select count(0) as count from chat_record where uuid = ? and direction=0");
    query.addBindValue(uuid);
    query.exec();
    query.next();
    int count = query.value("count").toInt();
    if(count == 0)
        return false;
    return true;
}

int DbHelper::getUnreadCount(QString userId, QString friendId)
{
    QSqlQuery query;
    query.prepare("select count(0) as count from chat_record where user_id=? and friend_id=? and direction=0 and is_read = 0");
    query.addBindValue(userId);
    query.addBindValue(friendId);
    query.exec();
    query.next();
    return query.value("count").toInt();
}
