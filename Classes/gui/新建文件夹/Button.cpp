#include "gui/Button.h"

USING_NS_CC;

Button::Button()
{
}

Button::~Button()
{
}

Button* Button::create(const char* image)
{
	Button* button = new Button();
	if (button->initWithImage(image))
	{
		button->autorelease();
		return button;
	}
	CC_SAFE_DELETE(button);
	return nullptr;
}

bool Button::initWithImage(const char* image)
{
	Widget::initWithFile(image);
	return true;
}
