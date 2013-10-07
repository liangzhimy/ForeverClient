#ifndef __APPMACROS_H__
#define __APPMACROS_H__
#include "cocos2d.h"

using namespace cocos2d;

#define VISIBLE_SIZE	= (Director::getInstance()->getVisibleSize())
#define ORIGIN			= (Director::getInstance()->getVisibleOrigin())
#define CENTER			= Point(ORIGIN.x + VISIBLE_SIZE.width/2, ORIGIN.y + VISIBLE_SIZE.height/2)


#endif /* __APPMACROS_H__ */
