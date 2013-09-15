#include "socket/SocketAddr.h"
#include <string.h>
#include <stdio.h>

#ifdef WIN32
#pragma comment(lib,"ws2_32.lib")
#endif

using namespace std;

SocketAddr::SocketAddr(const string ip,int port) :m_error(false)
{
	init(ip.c_str(),port);
}

SocketAddr::~SocketAddr() {}

void SocketAddr::init(const char* ip,int port)
{
	memset(&m_addr,0,sizeof(m_addr));
	m_addr.sin_family = AF_INET;
	m_addr.sin_port = htons(port);
	/************************************************************************/
	/* 如果函数出错将返回一个负值，并将errno设置为EAFNOSUPPORT，如果参数af指定的地址族和src格式不对，函数将返回0。 成功返回1                                                               */
	/************************************************************************/
	if (inet_pton(AF_INET,ip,&m_addr.sin_addr)!=1)
	{
		m_error = true;
	}
}

struct sockaddr_in* SocketAddr::getAddr()
{
	return &m_addr;
}

int SocketAddr::getAddrLenght()
{
	return sizeof(struct sockaddr_in);
}

bool SocketAddr::error()
{
	return m_error;
}