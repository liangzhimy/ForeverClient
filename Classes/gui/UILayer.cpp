#include "utils/Util.h"

#include "GUI/UILayer.h"
#include "GUI/Widget.h"
#include "GUI/GUIHelper.h"

USING_NS_CC;

UILayer::UILayer() : 
	_state(kUILayerStateWaiting), 
	_touchDownWidget(0), 
	_focusedWidget(0),
	_clickDt(0.3f),
	_doubleClickDt(0.3f),
	_holdDt(1.f)
{
	_singleClickStartTime = Util::getCurrentTimeUSec();
	_touchDownPos = Size::ZERO;
}

UILayer::~UILayer()
{
}

UILayer* UILayer::create()
{
	UILayer* pRet = new UILayer();
	if (pRet && pRet->init())
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}

UILayer * UILayer::create(const Color4B& color, GLfloat width, GLfloat height)
{
	UILayer * pLayer = new UILayer();
	if( pLayer && pLayer->initWithColor(color,width,height))
	{
		pLayer->autorelease();
		return pLayer;
	}
	CC_SAFE_DELETE(pLayer);
	return NULL;
}

UILayer * UILayer::create(const Color4B& color)
{
	UILayer * pLayer = new UILayer();
	if(pLayer && pLayer->initWithColor(color))
	{
		pLayer->autorelease();
		return pLayer;
	}
	CC_SAFE_DELETE(pLayer);
	return NULL;
}


void UILayer::onEnter()
{
	CCLayer::onEnter();
	setTouchEnabled(true);
}

void UILayer::onExit()
{
	CCLayer::onExit();
}


void UILayer::setZOrder(int z)
{
	//Director::getInstance()->getTouchDispatcher()->setPriority(-z, this);
}

bool UILayer::onTouchBegan(Touch* pTouch, Event* event)
{
	CC_UNUSED_PARAM(event);

	if (_state != kUILayerStateWaiting)
	{
		return false;
	}

	for (Node *c = this; c != NULL; c = c->getParent())
	{
		if (!c->isVisible() || !c->isRunning())
		{
			return false;
		}
	}
	
	_touchDownWidget = UIHelper::findTouchedWidget(pTouch,this);

	if (_focusedWidget && (_touchDownWidget != _focusedWidget))
	{
		_focusedWidget->lostFocus();
		_focusedWidget = 0;
	}

	if (_touchDownWidget)
	{
		_state = kUILayerStateTouchDown;
		_touchDownPos = pTouch->getLocation();
		//_lastDragPos = _touchDownPos;

		if (_touchDownWidget->isNeedFocus())
		{
			_touchDownWidget->gainFocus();
			_focusedWidget = _touchDownWidget;
		}

		_touchDownWidget->onTouchDown(_touchDownPos);

		_singleClickStartTime = Util::getCurrentTimeUSec();

		schedule(schedule_selector(UILayer::updateHold), _holdDt);
		return true;
	}

	return false;
}

void UILayer::onTouchEnded(Touch* pTouch, Event* event)
{
	if (_touchDownWidget)
	{
		Point touchUpPos = pTouch->getLocation();
		_touchDownWidget->onTouchUp(touchUpPos);

		long now = Util::getCurrentTimeUSec();
		float singlePassTime = (now - _singleClickStartTime) / 1000000.0;
		float doublePassTime = (now - _doubleClickStartTime) / 1000000.0;
		float moveed = (_touchDownPos - touchUpPos).getLengthSq();
		
		//CCLOG("singlePassTime %f doublePassTime %f ",singlePassTime,doublePassTime);

		if (singlePassTime < _clickDt && moveed < 40)
		{
			if (_prevTouchDownWidget 
				&& _prevTouchDownWidget == _touchDownWidget 
				&& doublePassTime < _doubleClickDt)
			{
				_touchDownWidget->onDoubleClick(_touchDownPos);
				_prevTouchDownWidget = 0;
			}
			else
			{
				_touchDownWidget->onClick(_touchDownPos);
				_doubleClickStartTime = now;
				_prevTouchDownWidget = _touchDownWidget;
			}
		}
		_touchDownWidget = 0;
		unschedule(schedule_selector(UILayer::updateHold));
	}

	_touchDownPos = Point::ZERO;
	_state = kUILayerStateWaiting;
}

void UILayer::onTouchCancelled(Touch *pTouch, Event* event)
{
	CC_UNUSED_PARAM(event);

	if (_touchDownWidget)
	{
		_touchDownWidget->onTouchUp(pTouch->getLocation());
		_touchDownWidget = 0;
	}
	_state = kUILayerStateWaiting;
}

void UILayer::onTouchMoved(Touch* pTouch, Event* event)
{
	CC_UNUSED_PARAM(event);

	if (_touchDownWidget)
	{
		Point curPos = pTouch->getLocation();
		Point prePos = pTouch->getPreviousLocation();
		_touchDownWidget->onDragMove(curPos, prePos);
		unschedule(schedule_selector(UILayer::updateHold));
	}
}

void UILayer::updateHold(float dt)
{
	if (_touchDownWidget)
		_touchDownWidget->onHold(_touchDownPos);

	unschedule(schedule_selector(UILayer::updateHold));
}
/**
void UILayer::addChild(Node * child, int zOrder, int tag )
{
	Widget *widget = dynamic_cast<Widget*>(child);
	if (widget)
		widget->setParentLayer(this);

	CCLayer::addChild(child, zOrder, tag);
}

void UILayer::addChild(Node * child)
{
	CCLayer::addChild(child);
}

void UILayer::addChild(cocos2d::Node * child, int zOrder)
{
	CCLayer::addChild(child, zOrder);
}

void UILayer::widgetDied(Widget *widget)
{
	if (widget == _focusedWidget)
	{
		_focusedWidget->lostFocus();
		_focusedWidget = 0;
	}

	if (widget == _focusedWidget)
	{
		_touchDownWidget = 0;
	}
}

*/