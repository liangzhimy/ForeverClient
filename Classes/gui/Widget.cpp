#include "gui/Widget.h"

USING_NS_CC;

const unsigned int	kNormalTag = 0x1;
const unsigned int	kSelectedTag = 0x2;
const unsigned int	kToggledTag = 0x3;
const unsigned int	kDisableTag = 0x4;

Widget::Widget() : 
    _needFocus(false), 
    _enabled(true),
    _selected(false), 
	_touchDownHandler(nullptr),
	_touchUpHandler(nullptr), 
	_clickedHandler(nullptr),
	_doubleClickedHandler(nullptr),
	_dragMoveHandler(nullptr),
	_holdHandler(nullptr)
{

}

Widget::~Widget()
{

}

Widget * Widget::create(const char *file )
{
	Widget *widget = new Widget;
	widget->initWithFile(file);
	widget->autorelease();
	return widget;
}

Widget * Widget::create(Sprite *spr )
{
	Widget *widget = new Widget;
	widget->initWithSprite(spr);
	widget->autorelease();
	return widget;
}

void Widget::initWithFile(const char *file )
{
	Sprite *spr = Sprite::create(file);
	initWithSprite(spr);
}

void Widget::initWithSprite(Sprite *spr )
{
	spr->setAnchorPoint(Point(0,0));
	spr->setPosition(Point(0, 0));
	addChild(spr);
	setContentSize(spr->getContentSize());
}

void Widget::onTouchDown(const Point& pos)
{
	_selected = true;

	if (_touchDownHandler)
	{
		_touchDownHandler(this, pos);
	}
}

void Widget::onTouchUp(const Point& pos)
{
	_selected = false;

	if (_touchUpHandler)
	{
		_touchUpHandler(this, pos);
	}
}

void Widget::onClick(const Point& pos)
{
	if (_clickedHandler)
	{
		_clickedHandler(this, pos);
	}
}

void Widget::onDoubleClick(const Point& pos)
{
	if (_doubleClickedHandler)
	{
		 _doubleClickedHandler(this, pos);
	}
}

void Widget::onDragMove(const Point& pos, const Point& prevPos)
{
	if (_dragMoveHandler)
	{
		 _dragMoveHandler(this, pos,prevPos);
	}
}


void Widget::onHold(const Point& pos)
{
	if (_holdHandler)
	{
		 _holdHandler(this, pos);
	}
}

void Widget::gainFocus()
{

}

void Widget::lostFocus()
{

}

WidgetDraggable * WidgetDraggable::create(const char * file)
{
	WidgetDraggable *widget = new WidgetDraggable();
	widget->initWithFile(file);
	widget->autorelease();
	return widget;
}

WidgetDraggable * WidgetDraggable::create(Sprite* spr)
{
	WidgetDraggable *widget = new WidgetDraggable();
	widget->initWithSprite(spr);
	widget->autorelease();
	return widget;
}

void WidgetDraggable::onDragMove(const Point& pos, const Point& prevPos)
{
	Widget::onDragMove(pos,prevPos);
	Point deltaPoint = this->convertToNodeSpace(pos) - this->convertToNodeSpace(prevPos);
	this->setPosition(getPosition() + deltaPoint);
}