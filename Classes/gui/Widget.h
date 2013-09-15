#ifndef __GUI_WIDGET_H__
#define __GUI_WIDGET_H__

#include "cocos2d.h"

USING_NS_CC;
class Widget;

typedef std::function<void(Widget*, Point)> TouchDownHandler;
typedef std::function<void(Widget*, Point)> TouchUpHandler;
typedef std::function<void(Widget*, Point)> ClickedHandler;
typedef std::function<void(Widget*, Point)> DoubleClickedHandler;
typedef std::function<void(Widget* node, Point)> HoldHandler;
typedef std::function<void(Widget* node, Point curPos, Point prevPos)> DragMoveHandler;

class UILayer;

/** 
 * UI控件的基类
 */
class Widget : public cocos2d::Node
{
public:

	static Widget* create(const char *file);
	
	static Widget* create(Sprite *spr);

protected:
	Widget();
	virtual ~Widget();

	void initWithSprite(Sprite *spr);
	void initWithFile(const char *file);

public:
    /* 手指在该控件上按下 */
    virtual void onTouchDown(const Point& pos);

    /* 松开手指，只有响应了touchDown的控件才会触发touchUp */
    virtual void onTouchUp(const Point& pos);

    /* 单击 */
    virtual void onClick(const Point& pos);

    /* 双击 */
    virtual void onDoubleClick(const Point& pos);

    /* 触发按下后移动 */
    virtual void onDragMove(const Point& pos, const Point& prevPos);

    /* 持续在该控件上按住 */
    virtual void onHold(const Point& pos);

	virtual void gainFocus();
	virtual void lostFocus();

	virtual bool isNeedFocus() const {return _needFocus;}
	virtual void setNeedFocus(bool needFocus) { _needFocus = needFocus; }
	
	virtual bool isEnabled()const {return _enabled;}
	virtual void setEnabled(bool enabled){_enabled = enabled;}
	
	virtual bool isSelected()const {return _selected;}

protected:
    bool			_needFocus;
	bool			_enabled;
	bool			_selected;

public:
	TouchDownHandler		_touchDownHandler;
    TouchUpHandler			_touchUpHandler;
    ClickedHandler			_clickedHandler;
    DoubleClickedHandler	_doubleClickedHandler;
    DragMoveHandler			_dragMoveHandler;
    HoldHandler				_holdHandler;

    int						_scriptClickedHandler;
    int						_scriptDoubleClickedHandler;
    int						_scriptDragMoveHandler;
    int						_scriptHoldHandler;
    int						_scriptTouchDownHandler;
    int						_scriptTouchUpHandler;
	int						_scriptGainFocusHandler;
	int						_scriptLostFocusHandler;
};


/**
 * 可拖动
 */
class WidgetDraggable : public Widget
{
public:
	static WidgetDraggable* create(const char* file);
	static WidgetDraggable* create(Sprite* spr);

protected:
	WidgetDraggable(){};
	virtual ~WidgetDraggable(){};
public:
    virtual void onDragMove(const Point& pos, const Point& prevPos);
};


#endif // __GUI_WIDGET_H__
