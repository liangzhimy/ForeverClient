#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#include "client/SocketClient.h"
#include "protocol/GameProtocol.pb.h"
#include "utils/Util.h"

#include "gui/VisibleRect.h"

using namespace com::qiyi::forever::master::protobuf;

class MainLayer : public cocos2d::LayerColor
{
public:
   
    virtual bool init();  
    
    void menuCloseCallback(Object* pSender);
    
    CREATE_FUNC(MainLayer);

	void onLoginResponse(LoginResponse* message);

	void onButtonClick(Node* button, Point pos);
};

#endif // __HELLOWORLD_SCENE_H__
