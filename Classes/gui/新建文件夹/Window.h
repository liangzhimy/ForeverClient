#ifndef __GUI_WINDOW_H__
#define __GUI_WINDOW_H__

#include "cocos2d.h"

#include "gui/Widget.h"
#include "gui/UIlayer.h"

USING_NS_CC;


/**
* 定义窗口，创建后会自动加入到当前运行的Scene中，位置居中
*/
class Window : public Widget
{
public:
	/**
	* 创建一个固定长宽，带背景颜色的窗口
	*/
	static Window* create(float width, float height,const Color4B& color);

	/**
	* 创建一个固定长宽的窗口
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
	* 用于放Window对象的层，可能不止放一个window对象
	*/
	static UILayer*	_layer;

	/**
	* 暂时用来保存 update函数调用的次数
	*/
	int			_frame;
};

#endif // __GUI_WINDOW_H__
