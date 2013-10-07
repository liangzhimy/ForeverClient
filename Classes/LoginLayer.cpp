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

	glClearColor(1.0, 1.0, 1.0, 1.0); 

    auto visibleSize = Director::getInstance()->getVisibleSize();
    auto origin = Director::getInstance()->getVisibleOrigin();
	auto center = Point(origin.x + visibleSize.width/2, origin.y + visibleSize.height/2);

	Configuration* config = Configuration::getInstance();

	auto bg = Sprite::create("login_bg.png");
	bg->setPosition(VisibleRect::center());
	this->addChild(bg);

	const char* labelPassport = Configuration::getInstance()->getCString("text.passport");
	CCLOG("labelPassport: %s",labelPassport);
	
	UIButton* textButton = UIButton::create();
    textButton->setTouchEnabled(true);
    textButton->loadTextures("white_10_10.png", "white_10_10.png", "");
	textButton->setTitleFontName("fonts/zhen_hei.ttf");
	textButton->setTitleText(config->getCString("button.login"));
	textButton->setTitleColor(Color3B(11,4,3));
	textButton->setTitleFontSize(24);
    textButton->setPosition(VisibleRect::center());
	textButton->setColor(Color3B(255,103,79));
	textButton->setSize(Size(106,36));
	textButton->setScale9Enabled(true);
    textButton->addTouchEventListener(this, toucheventselector(LoginLayer::onButtonClick));       
	textButton->setPressedActionEnabled(true);
	this->addWidget(textButton);

	auto inputBg = Sprite::create("input_bg.png");
	inputBg->setPosition(VisibleRect::center());
	//this->addChild(inputBg);

	auto editName = EditBox::create(Size(150,300), Scale9Sprite::create("extensions/green_edit.png"));

	return true;
}

void LoginLayer::onButtonClick(Object* sender,TouchEventType eventType)
{
	UIWidget* widget = (UIWidget*)sender;

	switch (eventType)
	{
	case TOUCH_EVENT_ENDED:
		//widget->setColor(Color3B(255,103,79));
		break;
	case TOUCH_EVENT_BEGAN:
		//widget->setColor(Color3B(0,255,0));
		break;
	default:
		break;
	}

}