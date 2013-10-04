#ifndef __GUI_LAYER_H__
#define __GUI_LAYER_H__

#include "cocos2d.h"

USING_NS_CC;

class Widget;

enum UILayerState  
{
	kUILayerStateWaiting,
	kUILayerStateTouchDown,
	kUILayerStateTouchMoving
};
enum {
	kUILayerTouchPriority = -64,
};

class UILayer : public LayerColor
{
public:
	UILayer();
	~UILayer();

	/** creates a fullscreen black layer */
	static UILayer* create();
	/** creates a Layer with color, width and height in Points */
	static UILayer* create(const Color4B& color, GLfloat width, GLfloat height);
	/** creates a Layer with color. Width and height are the window size. */
	static UILayer* create(const Color4B& color);

	virtual void onEnter();
	virtual void onExit();

	virtual bool onTouchBegan(Touch* touch, Event* event);
	virtual void onTouchEnded(Touch* touch, Event* event);
	virtual void onTouchCancelled(Touch *touch, Event* event);
	virtual void onTouchMoved(Touch* touch, Event* event);


	/**
	void removeWidget(Widget *widget);
	void widgetDied(Widget *widget);

	virtual void addChild(CCNode * child);
	virtual void addChild(CCNode * child, int zOrder);
	virtual void addChild(CCNode * child, int zOrder, int tag);
	*/
protected:

	void updateHold(float time);

private:
	virtual void setZOrder(int z);

protected:
	Widget*			_touchDownWidget;
	Widget*			_prevTouchDownWidget;
	Widget*			_focusedWidget;

	long			_singleClickStartTime;
	long			_doubleClickStartTime;
	float			_clickDt, _doubleClickDt, _holdDt;
	Point			_touchDownPos;
	//Point			_lastDragPos;
	UILayerState	_state;
};


#endif // __GUI_LAYER_H__
