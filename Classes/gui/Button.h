#ifndef __GUI_BUTTON_H__
#define __GUI_BUTTON_H__

#include "cocos2d.h"
#include "gui/Widget.h"

class Button : public Widget
{
public:
	static Button* create(const char* image);

    bool initWithImage(const char* image);

	virtual void setClickedHandler(ClickedHandler clickedHandler){_clickedHandler = clickedHandler;};

private:
	Button();
	virtual ~Button();
};


#endif // __GUI_BUTTON_H__
