#ifndef __LOADING_H__
#define __LOADING_H__

#include "cocos2d.h"
#include "client/SocketClient.h"

class LoginLayer
{
public:
	void addImage(const char* filename);
	void addJson(const char* filename);
	void addXML(const char* filename);
	void addSocketConnect(const SocketClient* socketClient);

	void start();
	void cancel();

	void onProcess();
	void onFinish();
};

#endif // __LOADING_H__
