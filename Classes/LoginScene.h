#ifndef __LOGIN_SCENE_H__
#define __LOGIN_SCENE_H__

#include "cocos2d.h"
#include "cocos-ext.h"

class LoginScene : public cocos2d::extension::UILayer
{
public:

    virtual bool init();  

    static cocos2d::Scene* scene();

    CREATE_FUNC(LoginScene);

	void onButtonClick(Object* sender,cocos2d::extension::TouchEventType eventType);
};

#endif // __LOGIN_SCENE_H__
