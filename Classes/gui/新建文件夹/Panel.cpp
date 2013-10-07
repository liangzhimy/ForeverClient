#include "gui/Panel.h"
#include "gui/VisibleRect.h"

Panel::Panel()
{
}

Panel::~Panel()
{
}

Panel* Panel::create(float width, float height)
{
	Panel* panel = new Panel();

	if (panel->init(Size(width,height)))
	{
		panel->autorelease();
		return panel;
	}
	CC_SAFE_DELETE(panel);
	return nullptr;
}

Panel* Panel::create(const Size& size)
{
	return Panel::create(size.width,size.height);
}

bool Panel::init(const Size& size)
{
	if (!Widget::init())
	{
		CCLOG("Panel init failed!");
		return false;
	}
	this->setContentSize(size);
	this->setAnchorPoint(Point(0,0));
	return true;
}

void Panel::visit()
{
	glEnable(GL_SCISSOR_TEST);              // 开启显示指定区域
	glScissor(0, 0, getContentSize().width, getContentSize().height);
	Widget::visit();                       // 调用下面的方法
	glDisable(GL_SCISSOR_TEST);            // 禁用
}