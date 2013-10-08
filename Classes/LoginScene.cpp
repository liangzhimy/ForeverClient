#include "LoginScene.h"

#include "gui/VisibleRect.h"
#include "AppMacros.h"

#include "event_dispatcher/CCEventListenerTouch.h"

USING_NS_CC;
USING_NS_CC_EXT;

Scene* LoginScene::scene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    LoginScene *layer = LoginScene::create();

    // add layer as a child to scene
    scene->addChild(layer);

    // return the scene
    return scene;
}

bool LoginScene::init()
{
	if ( !UILayer::init() )
    {
        return false;
    }
 
	glClearColor(1.0, 1.0, 1.0, 1.0); 

	auto root = dynamic_cast<Layout*>(CCUIHELPER->createWidgetFromJsonFile("SampleChangeEquip_1.ExportJson"));
    this->addWidget(root);

	Configuration* config = Configuration::getInstance();

	auto bg = Sprite::create("login_bg.png");
	bg->setPosition(VisibleRect::center());
	this->addChild(bg);
      
    auto label = UILabel::create();
    label->setText(config->getCString("label.password"));
    label->setFontSize(20);
	label->setColor(Color3B(11,4,3));
	label->setAnchorPoint(Point(0,0));
    label->setPosition(Point(360,262));
    this->addWidget(label); 

    label = UILabel::create();
    label->setText(config->getCString("label.passport"));
    label->setFontSize(20);
	label->setColor(Color3B(11,4,3));
	label->setAnchorPoint(Point(0,0));
    label->setPosition(Point(360,214));
    this->addWidget(label); 

	auto editBox = EditBox::create(Size(192,32), Scale9Sprite::create("input_bg_2.png"));
	editBox->setAnchorPoint(Point(0,0));
	editBox->setPosition(Point(425,257));
	this->addChild(editBox);

	editBox = EditBox::create(Size(192,32), Scale9Sprite::create("input_bg_2.png"));
	editBox->setInputFlag(EditBox::InputFlag::PASSWORD);
	editBox->setAnchorPoint(Point(0,0));
	editBox->setPosition(Point(425,209));
	this->addChild(editBox);

	auto textButton = UIButton::create();
    textButton->setTouchEnabled(true);
    textButton->loadTextures("white_10_10.png", "white_10_10.png", "");
	textButton->setTitleText(config->getCString("button.login"));
	textButton->setTitleColor(Color3B(11,4,3));
	textButton->setTitleFontSize(24);
    textButton->setPosition(Point(425,173));
	textButton->setColor(Color3B(255,103,79));
	textButton->setSize(Size(106,35));
	textButton->setScale9Enabled(true);
    textButton->addTouchEventListener(this, toucheventselector(LoginScene::onButtonClick));       
	textButton->setPressedActionEnabled(true);
	this->addWidget(textButton);

	textButton = UIButton::create();
    textButton->setTouchEnabled(true);
    textButton->loadTextures("white_10_10.png", "white_10_10.png", "");
	textButton->setTitleText(config->getCString("button.regist"));
	textButton->setTitleColor(Color3B(11,4,3));
	textButton->setTitleFontSize(24);
    textButton->setPosition(Point(555,173));
	textButton->setColor(Color3B(255,255,0));
	textButton->setSize(Size(106,35));
	textButton->setScale9Enabled(true);
    textButton->addTouchEventListener(this, toucheventselector(LoginScene::onButtonClick));       
	textButton->setPressedActionEnabled(true);
	this->addWidget(textButton);
    return true;
}

void LoginScene::onButtonClick(Object* sender,TouchEventType eventType)
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