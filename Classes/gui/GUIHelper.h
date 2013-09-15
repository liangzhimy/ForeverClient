#ifndef __GUI_HELPER_H__
#define __GUI_HELPER_H__

#include <functional>
#include "cocos2d.h"
#include "gui/Widget.h"

USING_NS_CC;

class UIHelper
{
public:

	static bool checkTouchable(Node* node)
	{
		Node* parent = node;
		while (parent)
		{
			if (!parent->isVisible() || !parent->isRunning())
			{
				return false;
			}
			parent = parent->getParent();
		}
		return true;
	}

	static Node* findTouchedNode(Touch *pTouch, Node* parent)
	{
		Point touchLocation = pTouch->getLocation();
		if (parent->getChildrenCount() > 0)
		{
			Object* pObject = NULL;
			CCARRAY_FOREACH_REVERSE(parent->getChildren(), pObject)
			{
				Node* node = dynamic_cast<Node*>(pObject);
				if (node == nullptr 
					|| !node->isVisible() 
					|| !node->isRunning())
				{
					continue;
				}
				
				Widget* widget = dynamic_cast<Widget*>(pObject);
				if (widget==nullptr || !widget->isEnabled())
				{
					continue;
				}
				
				Point local = node->convertToNodeSpace(touchLocation);
				Rect r = node->getBoundingBox();
				r.origin = Point::ZERO;

				if (r.containsPoint(local))
				{
					Node* founded = findTouchedNode(pTouch,widget);
					return founded ? founded : widget;
				}
			}
		}
		return nullptr;
	}

	static Widget* findTouchedWidget(Touch *pTouch, Node* parent)
	{
		Point touchLocation = pTouch->getLocation();
		if (parent && parent->getChildrenCount() > 0)
		{
			Object* pObject = NULL;
			CCARRAY_FOREACH_REVERSE(parent->getChildren(), pObject)
			{
				Widget* widget = dynamic_cast<Widget*>(pObject);
				if (widget == nullptr 
					|| !widget->isVisible()
					|| !widget->isRunning() 
					|| !widget->isEnabled())
				{
					continue;
				}

				Point local = widget->convertToNodeSpace(touchLocation);
				Rect r = widget->getBoundingBox();
				r.origin = Point::ZERO;

				if (r.containsPoint(local))
				{
					Widget* founded = findTouchedWidget(pTouch,widget);
					return founded ? founded : widget;
				}
			}
		}
		return nullptr;
	}
private:
	UIHelper();
	virtual ~UIHelper();
};

#endif // __GUI_HELPER_H__
