#include "client/SocketMgr.h"

SocketClient* SocketMgr::_socketClient = nullptr;

SocketMgr::SocketMgr()
{
	
}

SocketMgr::~SocketMgr()
{
}

SocketClient* SocketMgr::get()
{
	return _socketClient;
}

void SocketMgr::set(SocketClient* socketClient)
{
	_socketClient = socketClient;
}