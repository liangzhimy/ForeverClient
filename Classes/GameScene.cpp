#include "GameScene.h"

bool GameScene::init()
{
	GameContext* gameContext = GameContext::getInstance();
	_loginLayer = LoginLayer::create();
	this->addChild(_loginLayer);
	return true;
}
