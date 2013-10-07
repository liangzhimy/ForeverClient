#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <map>
#include "MainLayer.h"
#include "client/SocketMgr.h"
#include "cocos-ext.h"
#include "protocol/GameProtocol.pb.h"


USING_NS_CC_EXT;

bool MainLayer::init()
{
  
    Size visibleSize = Director::getInstance()->getVisibleSize();
    Point origin = Director::getInstance()->getVisibleOrigin();

	Size winSize = Director::getInstance()->getWinSizeInPixels();
	std::map<std::string,std::string> map;
	map["ss"] = "dsadsa";

	CCLOG("visibleSize width  %f height %f origin.x %f origin.y %f",visibleSize.width,visibleSize.height,origin.x,origin.y);
	CCLOG("winSize width  %f height %f origin.x %f origin.y %f",winSize.width,winSize.height,origin.x,origin.y);

	Sprite* bg = Sprite::create("UI/public/bg.png");
	bg->setAnchorPoint(Point(0.5,0.5));
	bg->setPosition(VisibleRect::center());
	//this->addChild(bg);
	/**
	Button* button = Button::create("UI/public/back_btn.png");
	button->setPosition(CCPoint(visibleSize.width/4,visibleSize.height/4));
	button->setClickedHandler(CC_CALLBACK_2(MainLayer::onButtonClick,this));
	this->addChild(button);

	//Window* window = Window::create(100.f,100.f,Color4B(255,32,57,255));

	Panel* panel = Panel::create(200.f,150.f);
	panel->setAnchorPoint(Point(0,0));
	panel->setPosition(100,100);
	this->addChild(panel);

	Sprite* sprite2 = Sprite::create("UI/public/locked_k.png");
	sprite2->setAnchorPoint(Point(0,0));
	sprite2->setPosition(Point(0,0));
	this->addChild(sprite2);

	WidgetDraggable* widgetDraggable = WidgetDraggable::create("UI/public/back_btn.png");
	widgetDraggable->setAnchorPoint(Point(0,0));
	widgetDraggable->setPosition(Point(100,100));
	this->addChild(widgetDraggable);

	Scale9Sprite* scale9Sprite = Scale9Sprite::create("UI/public/recuit_dark.png");
	scale9Sprite->setAnchorPoint(Point(0.5,0.5));
	scale9Sprite->setPosition(VisibleRect::center());
	scale9Sprite->setContentSize(Size(200,100));
	this->addChild(scale9Sprite);
	*/
	return true;
}

void MainLayer::onButtonClick(Node* button,Point pos)
{
	CCLOG("button clicked");
	TextureCache::getInstance()->dumpCachedTextureInfo();
}

void MainLayer::onLoginResponse(LoginResponse* message)
{
	CCLOG("onLoginResponse...%s errorcode %d",message->msg().c_str(),message->errorcode());
}

void MainLayer::menuCloseCallback(Object* pSender)
{
	SocketClient* socketClient = SocketClient::createSocketClient("127.0.0.1",12345);
	socketClient->retain();
	SocketMgr::set(socketClient);

	socketClient = SocketMgr::get();

	auto callback = std::bind(&MainLayer::onLoginResponse,this,std::placeholders::_1);
	socketClient->registCallbackT<LoginResponse>(1,callback);

	if (socketClient->connect())
	{
		LoginRequest* loginRequestMessage = new LoginRequest();
		loginRequestMessage->set_username("cmzx3444");
		loginRequestMessage->set_password("123456");
		socketClient->send(loginRequestMessage);

		loginRequestMessage = new LoginRequest();
		loginRequestMessage->set_username("cmzx3444");
		loginRequestMessage->set_password("123456");
		socketClient->send(loginRequestMessage);

		loginRequestMessage = new LoginRequest();
		loginRequestMessage->set_username("cmzx3444");
		loginRequestMessage->set_password("123456");
		socketClient->send(loginRequestMessage);

		loginRequestMessage = new LoginRequest();
		loginRequestMessage->set_username("cmzx3444");
		loginRequestMessage->set_password("123456");
		socketClient->send(loginRequestMessage);
	}
	else
	{
		socketClient->release();
	}

    Director::getInstance()->end();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    exit(0);
#endif
}
