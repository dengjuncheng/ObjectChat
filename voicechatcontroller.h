#ifndef VOICECHATCONTROLLER_H
#define VOICECHATCONTROLLER_H

#include <QObject>
#include<QThread>

class VoiceChatService;
class VoiceChatController : public QObject
{
    Q_OBJECT
public:
    explicit VoiceChatController(QObject *parent = nullptr);
    ~VoiceChatController();
signals:
    void startVoiceChat(QString idAddress);
public slots:
private:
    QThread m_workThread;
    VoiceChatService *m_service;
};

#endif // VOICECHATCONTROLLER_H
