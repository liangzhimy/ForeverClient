#include "GameContext.h"

using namespace cocos2d;

GameContext* GameContext::s_Instance = nullptr;

GameContext::GameContext()
{
	s_Instance = this;
	_socketClinet = SocketClient::createSocketClient("127.0.0.1",12345);
	Configuration::getInstance()->loadConfigFile("config.plist");
}

GameContext::~GameContext()
{

}

GameContext* GameContext::getInstance()
{
	if(s_Instance == nullptr)
	{
		s_Instance = new GameContext();
	}
	return s_Instance;
}