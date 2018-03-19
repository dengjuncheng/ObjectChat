#ifndef VOICECHATSERVICE_H
#define VOICECHATSERVICE_H

#include <QObject>
#include <QAudioInput>
#include <QUdpSocket>
#include <QAudioOutput>


class VoiceChatService : public QObject
{
    Q_OBJECT
public:
    explicit VoiceChatService(QObject *parent = nullptr);

signals:

public slots:
    void onReadSendRequest(QString ipAdress);
    void onInputReadyRead();//可以从设备中读取音频数据时调用此方法
    void onRequestMsgRecived();
    void close();
private:
    QAudioInput *m_audioInput = 0;
    QAudioOutput *m_audioOutput = 0;
    QUdpSocket *m_writeSocket;
    QUdpSocket *m_readSocket;
    QIODevice *inputDevice;
    QIODevice *outputDevice;
    qint16 m_port;
    QString m_localAddress;
    QString m_anotherAddress;
    bool flag;
    int count;
private:
    void init();
};

struct AudioPack
{
    AudioPack() {}
    char data[1024];
    int length;
};

#endif // VOICECHATSERVICE_H
