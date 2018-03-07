#ifndef INTERACTIONCENTER_H
#define INTERACTIONCENTER_H

#include <QObject>
/**qml与C++交互类
 * @brief The InteractionCenter class
 */
class CaptureScreen;
class FileHelper;
class ConnectionCenter;
class UploadController;
class MessageController;
class VoiceChatController;
class InteractionCenter : public QObject
{
    Q_OBJECT
public:
    explicit InteractionCenter(CaptureScreen *obj, FileHelper *obj2, ConnectionCenter * conn, QObject *parent = nullptr);
    ~InteractionCenter();
signals:
    void signalCompleteCature(QString filePath);
    void msgHasBeenSent(QString msg);
    void newMsg(QString msg);
    void voiceChatRequestResult(QString msg);
public slots:
    void addContact(QString userId, QString friendId);
    QString getContactByUserId(QString userId);
    void updateContactAddTime(QString userId,QString friendId);
    QString getCurrentDateTime(QString format);
    void capture();
    QString getChatRecordByUserId(QString userId, QString friendId);
    void updateReadMsg(QString userId, QString friendId);//该方法弃用
    QString getLastMsg(QString userId, QString friendId);
    QString getDateString(int timestamp, QString format);
    void sendMsg(QString userId, QString friendId, QString msg, QString text);
    void msgStateChanged(QString uuid);
    void sendTextMsg(QString msg);
    void updateMsgState(QString uuid);
    void getUnreadMsg(QString stuId);
    int getUnreadCount(QString userId, QString friendId);
    void voiceChatRequest(QString userId, QString friendId);
    void readyVoiceChat(QString userId, QString friendId);
private:
    CaptureScreen *captureScreen;
    FileHelper *fileHelper;
    ConnectionCenter *m_conn;
    UploadController * m_uploadController;
    MessageController *m_messageController;
    VoiceChatController *m_voiceChatController;
};

enum MsgType
{
    TYPE_TEXT=1,
    TYPE_PNG,
    TYPE_FILE
};

#endif // INTERACTIONCENTER_H
