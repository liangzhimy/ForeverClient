#ifndef __GAME_SCENE_H__
#define __GAME_SCENE_H__

#include "cocos2d.h"
#include "GameContext.h"
#include "MainLayer.h"
#include "LoginLayer.h"

class GameScene : public cocos2d::Scene
{
public:
   
    virtual bool init();  

    CREATE_FUNC(GameScene);

private:
	
	MainLayer*	_mainLayer;
	LoginLayer*	_loginLayer;
};

#endif // __GAME_SCENE_H__
