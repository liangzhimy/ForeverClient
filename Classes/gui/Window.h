#ifndef __GUI_WINDOW_H__
#define __GUI_WINDOW_H__

#include "cocos2d.h"

#include "gui/Widget.h"
#include "gui/UIlayer.h"

USING_NS_CC;


/**
* ���崰�ڣ���������Զ����뵽��ǰ���е�Scene�У�λ�þ���
*/
class Window : public Widget
{
public:
	/**
	* ����һ���̶�������������ɫ�Ĵ���
	*/
	static Window* create(float width, float height,const Color4B& color);

	/**
	* ����һ���̶�����Ĵ���
	*/
	static Window* create(float width, float height);

	static Window* create(const Size& size);

	Window();
	virtual ~Window();

	bool init(const Size& size,const Color4B& color);

	void show();

	void hide();

	void close();
private:
	/**
	* ���ڷ�Window����Ĳ㣬���ܲ�ֹ��һ��window����
	*/
	static UILayer*	_layer;

	/**
	* ��ʱ�������� update�������õĴ���
	*/
	int			_frame;
};

#endif // __GUI_WINDOW_H__
