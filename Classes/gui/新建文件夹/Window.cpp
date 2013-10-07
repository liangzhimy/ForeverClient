#include "gui/Window.h"
#include "gui/VisibleRect.h"

Window::Window():
	_frame(0)
{
}

Window::~Window()
{
}

Window* Window::create(float width, float height,const Color4B& color)
{
	Window* window = new Window();
	if (window->init(Size(width,height),color))
	{
		window->autorelease();
		return window;
	}
	CC_SAFE_DELETE(window);
	return nullptr;
}

Window* Window::create(float width, float height)
{
	return Window::create(width,height,Color4B(0,0,0,255));
}

Window* Window::create(const Size& size)
{
	return Window::create(size.width,size.height);
}

bool Window::init(const Size& size,const Color4B& color)
{
	Size visibleSize = Director::getInstance()->getVisibleSize();
	Point origin = Director::getInstance()->getVisibleOrigin();

	Point winCenter = VisibleRect::center();

	Point center = Point(winCenter.x - size.width/2,winCenter.y - size.height/2);
	this->setPosition(center);

	return true;
}

/**
void Window::addToRunningScene()
{
	Scene* runningScene = Director::getInstance()->getRunningScene();
	if (!runningScene)
	{
		CCLOG("no running scene, do it in next frame");
		Director::getInstance()->getScheduler()->scheduleUpdateForTarget(this,0,false);
	}
	else
	{
		runningScene->addChild(this);
	}
}

void Window::update(float time)
{
	//ÑÓ³Ùµ½ÏÂÒ»Ö¡
	if (_frame++ > 0)
	{
		Director::getInstance()->getScheduler()->unscheduleUpdateForTarget(this);

		Scene* runningScene = Director::getInstance()->getRunningScene();
		if (!runningScene)
		{
			CCLOG("no running scene");
			this->release();
			return;
		}
		runningScene->addChild(this);
	}
}
void Window::setColor(const Color3B& color)
{
LayerColor::setColor(color);
}
*/


void Window::show()
{
	this->setVisible(true);
}

void Window::hide()
{
	this->setVisible(false);
}

void Window::close()
{
}
