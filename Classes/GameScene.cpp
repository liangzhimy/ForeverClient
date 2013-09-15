#include "GameScene.h"

bool GameScene::init()
{
	_mainLayer = MainLayer::create();
	this->addChild(_mainLayer);
	return true;
}
