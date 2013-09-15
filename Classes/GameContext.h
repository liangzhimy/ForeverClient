#ifndef __GAME_CONTEXT_H__
#define __GAME_CONTEXT_H__

#include "cocos2d.h"
#include "client/SocketClient.h"

class GameContext
{
public:
	GameContext();
	~GameContext();

private:
	static GameContext* Instance;
};

#endif // __GAME_CONTEXT_H__
