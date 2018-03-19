#include "voicechatcontroller.h"
#include <voicechatservice.h>

VoiceChatController::VoiceChatController(QObject *parent) : QObject(parent)
{
    m_service = new VoiceChatService;
    m_service->moveToThread(&m_workThread);
    m_workThread.start();
    connect(this,&VoiceChatController::startVoiceChat,m_service,&VoiceChatService::onReadSendRequest);
    connect(this,&VoiceChatController::stop,m_service, &VoiceChatService::close);
}

VoiceChatController::~VoiceChatController()
{
    m_workThread.exit(0);
    m_workThread.terminate();
    delete m_service;
}

void VoiceChatController::interrupt()
{
    emit stop();
}
