#ifndef __HELLOWORLD_SCENE_H__
#define __HELLOWORLD_SCENE_H__

#include "cocos2d.h"
#include "client/SocketClient.h"
#include "protocol/GameProtocol.pb.h"
#include "utils/Util.h"

#include "GUI/UILayer.h"
#include "gui/Window.h"
#include "gui/Button.h"
#include "gui/Panel.h"
#include "gui/VisibleRect.h"

using namespace com::qiyi::forever::master::protobuf;

class MainLayer : public UILayer
{
public:
   
    virtual bool init();  
    
    void menuCloseCallback(Object* pSender);
    
    CREATE_FUNC(MainLayer);

	void onLoginResponse(LoginResponse* message);

	void onButtonClick(Node* button, Point pos);
};

#endif // __HELLOWORLD_SCENE_H__
