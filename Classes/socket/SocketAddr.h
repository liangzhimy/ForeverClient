#ifndef _SOCKET_ADDR_H_
#define _SOCKET_ADDR_H_

#include <string>

#if defined(_LINUX) || defined (_DARWIN)
#include <sys/socket.h>
#include <arpa/inet.h>
#endif

#if defined WIN32 || defined _WINDOWS
#include <winsock2.h>
#include <Ws2tcpip.h>
#endif

#include "AppMacros.h"

class SocketAddr{
    
public:
	SocketAddr(const std::string ip,int port);

    ~SocketAddr();

	void init(const char* ip,int port);

	struct sockaddr_in* getAddr();

	int getAddrLenght();

	bool error();

private:
	struct sockaddr_in		m_addr;
	bool					m_error;
};

#endif
