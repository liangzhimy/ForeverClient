#ifndef __LOGIN_LAYER_H__
#define __LOGIN_LAYER_H__

#include "cocos2d.h"
#include "client/SocketClient.h"
#include "protocol/GameProtocol.pb.h"
#include "utils/Util.h"

#include "GUI/UILayer.h"
#include "gui/Window.h"
#include "gui/Button.h"
#include "gui/Panel.h"
#include "gui/VisibleRect.h"

class LoginLayer : public UILayer
{
public:
   
    virtual bool init();  
    
    void menuCloseCallback(Object* pSender);
    
    CREATE_FUNC(LoginLayer);

	void onLoginResponse(ProtobufMessage* message);

	void onButtonClick(Node* button, Point pos);
};

#endif // __LOGIN_LAYER_H__
