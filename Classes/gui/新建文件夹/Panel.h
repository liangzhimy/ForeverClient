#ifndef __GUI_PANEL_H__
#define __GUI_PANEL_H__

#include "cocos2d.h"
#include "gui/Widget.h"

USING_NS_CC;

/**
* ��壬һ��������ڹ������沼��
*/
class Panel : public Widget
{
public:
	/**
	* ����һ���̶�����Ĵ���
	*/
	static Panel* create(float width, float height);

	static Panel* create(const Size& size);

	Panel();
	virtual ~Panel();

	bool init(const Size& size);

	virtual void visit();
};

#endif // __GUI_WINDOW_H__
