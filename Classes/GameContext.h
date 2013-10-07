#ifndef __GAME_CONTEXT_H__
#define __GAME_CONTEXT_H__

#include "cocos2d.h"
#include "client/SocketClient.h"

class GameContext
{
public:
	GameContext();
	~GameContext();
	
	SocketClient* getSocketClient(){return _socketClinet;}

	static GameContext* getInstance();

private:
	SocketClient* _socketClinet;
	static GameContext* s_Instance;
};

#endif // __GAME_CONTEXT_H__
