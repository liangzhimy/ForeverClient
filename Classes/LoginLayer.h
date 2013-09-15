#ifndef __LOGIN_LAYER_H__
#define __LOGIN_LAYER_H__

#include "cocos2d.h"
#include "client/SocketClient.h"
#include "protocol/GameProtocol.pb.h"
#include "utils/Util.h"

#include "GUI/UILayer.h"
#include "gui/Button.h"
#include "gui/Panel.h"

class LoginLayer : public UILayer
{
public:
   
    virtual bool init();  
    
    CREATE_FUNC(LoginLayer);

	void onLoginResponse(ProtobufMessage* message);

	void onButtonClick(Node* button, Point pos);
};

#endif // __LOGIN_LAYER_H__
