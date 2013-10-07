#include "LoginLayer.h"
#include "AppMacros.h"

#include "client/SocketClient.h"
#include "GameContext.h"
#include "gui/VisibleRect.h"
using namespace cocos2d;


bool LoginLayer::init()
{
	if(!UILayer::init())
	{
		return false;
	}

	//glClearColor(1.0, 1.0, 1.0, 1.0); 
    auto visibleSize = Director::getInstance()->getVisibleSize();
    auto origin = Director::getInstance()->getVisibleOrigin();
	auto center = Point(origin.x + visibleSize.width/2, origin.y + visibleSize.height/2);



	auto bg = Sprite::create("login_bg.png");
	bg->setPosition(VisibleRect::center());
	this->addChild(bg);

	const char* labelPassport = Configuration::getInstance()->getCString("text.passport");
	CCLOG("labelPassport: %s",labelPassport);
	
	UIButton* textButton = UIButton::create();
    textButton->setTouchEnabled(true);
    textButton->loadTextures("backtotopnormal.png", "backtotoppressed.png", "");
    textButton->setTitleText("Text Button");
    textButton->setPosition(VisibleRect::center());
	textButton->setCascadeColorEnabled(true);
	textButton->setColor(Color3B(99,99,99));
    //textButton->addTouchEventListener(this, toucheventselector(UITextButtonTest::touchEvent));        
	this->addWidget(textButton);

	return true;
}

