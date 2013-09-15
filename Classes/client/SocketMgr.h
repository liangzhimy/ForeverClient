#ifndef __SOCKET_MGR_H__
#define __SOCKET_MGR_H__

#include "client/SocketClient.h"

class SocketClient;
/**
* ������ȡSocketClient��SocketClient�����ȴ���
*/
class SocketMgr
{
public:

	/**
	* ���SocketClient
	*/
	static SocketClient* get();

	/**
	* ���SocketClient
	*/
	static void	set(SocketClient* socketClient);

private:
	SocketMgr();
	virtual ~SocketMgr();

private:
	static SocketClient*	_socketClient;
};

#endif // __SOCKET_MGR_H__
