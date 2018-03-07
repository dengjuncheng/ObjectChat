#include "voicechatcontroller.h"
#include <voicechatservice.h>

VoiceChatController::VoiceChatController(QObject *parent) : QObject(parent)
{
    m_service = new VoiceChatService;
    m_service->moveToThread(&m_workThread);
    m_workThread.start();
    connect(this,&VoiceChatController::startVoiceChat,m_service,&VoiceChatService::onReadSendRequest);
}

VoiceChatController::~VoiceChatController()
{
    m_service->deleteLater();
    m_workThread.exit(0);
}
