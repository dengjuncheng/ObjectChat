#include "voicechatservice.h"
#include <QAudioFormat>
#include <QIODevice>
#include <QDebug>
#include <QThread>
VoiceChatService::VoiceChatService(QObject *parent) : QObject(parent),
     m_writeSocket(new QUdpSocket(this)),m_readSocket(new QUdpSocket(this))
{
    m_port = 8088;
    //init();
}

//收到ip地址，开始发送和接收数据
void VoiceChatService::onReadSendRequest(QString ipAdress)
{
    QHostAddress host;
    if(!host.setAddress(ipAdress)){
        qDebug() << "VoiceChat::"<< "错误的目标ip地址:" << ipAdress;
        return;
    }
    m_anotherAddress = ipAdress;
    QAudioFormat format;
    format.setSampleRate(8000);
    format.setChannelCount(1);
    format.setSampleSize(16);
    format.setCodec("audio/pcm");
    format.setSampleType(QAudioFormat::SignedInt);
    format.setByteOrder (QAudioFormat::LittleEndian);
    if(m_audioInput == Q_NULLPTR)
    {
        m_audioInput = new QAudioInput(format, this);
    }
    if(m_audioOutput == Q_NULLPTR)
    {
        QAudioFormat outFormat(format);
        m_audioOutput = new QAudioOutput(outFormat, this);
    }

    QAudioDeviceInfo info = QAudioDeviceInfo::defaultInputDevice();
    if (!info.isFormatSupported(format))
    {
        qDebug()<<"default format not supported try to use nearest";
        format = info.nearestFormat(format);
    }

    inputDevice = m_audioInput->start();
    outputDevice = m_audioOutput->start();
    inputDevice->open(QIODevice::ReadOnly);
    outputDevice->open(QIODevice::WriteOnly);
    this->m_anotherAddress = ipAdress;
    m_readSocket->bind(QHostAddress::AnyIPv4, m_port, QUdpSocket::ShareAddress | QUdpSocket::ReuseAddressHint);
    //m_readSocket->joinMulticastGroup (QHostAddress("224.0.0.0"));
    connect(m_readSocket, &QUdpSocket::readyRead, this, &VoiceChatService::onRequestMsgRecived);
    connect(inputDevice,&QIODevice::readyRead,this,&VoiceChatService::onInputReadyRead);
}

void VoiceChatService::onInputReadyRead()
{
    AudioPack ap;
    memset(&ap, 0 , sizeof(ap));
    ap.length = inputDevice->read(ap.data, 1024);
    m_writeSocket->writeDatagram((const char*)&ap, sizeof(ap), QHostAddress(m_anotherAddress), m_port);
}

void VoiceChatService::onRequestMsgRecived()
{
    AudioPack ap;
    memset(&ap, 0 , sizeof(ap));
    //qDebug() << ap.length;
    m_readSocket->readDatagram((char*)&ap,sizeof(ap));
    outputDevice->write(ap.data, ap.length);
}

void VoiceChatService::close()
{
    m_audioInput->stop();
    m_audioOutput->stop();
    if(inputDevice->isOpen())
    {
        inputDevice->close();
    }
    if(outputDevice->isOpen())
    {
        outputDevice->close();
    }
    m_readSocket->disconnectFromHost();
    m_writeSocket->disconnectFromHost();
    disconnect(m_readSocket, &QUdpSocket::readyRead, this, &VoiceChatService::onRequestMsgRecived);
    disconnect(inputDevice,&QIODevice::readyRead,this,&VoiceChatService::onInputReadyRead);
}

void VoiceChatService::init()
{
    qDebug() << QThread::currentThread();
    QAudioFormat format;
    format.setSampleRate(8000);
    format.setChannelCount(1);
    format.setSampleSize(16);
    format.setCodec("audio/pcm");
    format.setSampleType(QAudioFormat::SignedInt);
    format.setByteOrder (QAudioFormat::LittleEndian);
    m_audioInput = new QAudioInput(format, this);

    QAudioFormat outFormat(format);
    outFormat.setByteOrder(QAudioFormat::LittleEndian);
    m_audioOutput = new QAudioOutput(outFormat, this);

    m_localAddress = "127.0.0.1";
    m_port = 8088;
    flag = true; //这个flag来区分请求方，true代表请求方，false代表发送方。接收时，传递该参数，让对应的socket绑定对应的port
}
