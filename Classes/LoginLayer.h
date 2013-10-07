#ifndef __LOGIN_LAYER_H__
#define __LOGIN_LAYER_H__

#include "cocos2d.h"
#include "cocos-ext.h"
#include "protocol/GameProtocol.pb.h"

USING_NS_CC_EXT;
using namespace com::qiyi::forever::master::protobuf;

class LoginLayer : public UILayer
{
public:
   
    virtual bool init();  
    
    CREATE_FUNC(LoginLayer);

	void onLoginResponse(LoginResponse* message);

	void onButtonClick(Object* sender,TouchEventType eventType);
};

#endif // __LOGIN_LAYER_H__
