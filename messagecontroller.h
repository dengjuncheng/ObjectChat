#ifndef MESSAGECONTROLLER_H
#define MESSAGECONTROLLER_H

#include <QObject>
#include <QDateTime>

class ConnectionCenter;
class MessageController : public QObject
{
    Q_OBJECT
public:
    explicit MessageController(ConnectionCenter * conn, QObject *parent = nullptr);

signals:
    void newMsg(QString msg);
public slots:
    void onNewMsg(QString msg);
    void onMsgSendSuccess(QString msg);
    void onUnreadMsgResult(QString msg);
private:
    ConnectionCenter *m_conn;
};
struct MsgInfo
{
    MsgInfo() {}
    QString userId;
    QString friendId;
    QString fileName;
    QString uuid;
    QString msg;
    bool direction;
    int msgType;
    QDateTime sendTime;
    QString filePath;
};

#endif // MESSAGECONTROLLER_H
