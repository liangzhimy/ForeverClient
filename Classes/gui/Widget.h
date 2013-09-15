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
 * UI�ؼ��Ļ���
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
    /* ��ָ�ڸÿؼ��ϰ��� */
    virtual void onTouchDown(const Point& pos);

    /* �ɿ���ָ��ֻ����Ӧ��touchDown�Ŀؼ��Żᴥ��touchUp */
    virtual void onTouchUp(const Point& pos);

    /* ���� */
    virtual void onClick(const Point& pos);

    /* ˫�� */
    virtual void onDoubleClick(const Point& pos);

    /* �������º��ƶ� */
    virtual void onDragMove(const Point& pos, const Point& prevPos);

    /* �����ڸÿؼ��ϰ�ס */
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
 * ���϶�
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
