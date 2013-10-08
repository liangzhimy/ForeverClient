#include "GameContext.h"

using namespace cocos2d;

GameContext* GameContext::s_Instance = nullptr;

GameContext::GameContext()
{
	s_Instance = this;
}

GameContext::~GameContext()
{

}

void GameContext::init()
{
	_socketClinet = SocketClient::createSocketClient("127.0.0.1",12345);
	Configuration::getInstance()->loadConfigFile("string.xml");
}

GameContext* GameContext::getInstance()
{
	if(s_Instance == nullptr)
	{
		s_Instance = new GameContext();
	}
	return s_Instance;
}