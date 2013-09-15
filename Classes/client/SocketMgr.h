#ifndef __SOCKET_MGR_H__
#define __SOCKET_MGR_H__

#include "client/SocketClient.h"

class SocketClient;
/**
* 用来获取SocketClient，SocketClient必须先创建
*/
class SocketMgr
{
public:

	/**
	* 获得SocketClient
	*/
	static SocketClient* get();

	/**
	* 获得SocketClient
	*/
	static void	set(SocketClient* socketClient);

private:
	SocketMgr();
	virtual ~SocketMgr();

private:
	static SocketClient*	_socketClient;
};

#endif // __SOCKET_MGR_H__
