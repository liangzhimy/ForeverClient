#include <socket/Socket.h>
#include "cocos2d.h"

Socket::Socket() :
	m_socket(INVALID_SOCKET),
	m_socketAddr(NULL),
	m_blocking(true),
	m_socketErrno(SocketSuccess)
{
#if defined(WIN32) || defined(WINDOWS)
	memset(&m_hWSAData, 0, sizeof(m_hWSAData));
	WSAStartup(MAKEWORD(2, 0), &m_hWSAData);
#endif
}

Socket::~Socket() 
{
	if (m_socketAddr)
	{
		delete m_socketAddr;
		m_socketAddr = NULL;
	}

#if defined(WIN32) || defined(WINDOWS)
	/************************************************************************
	/* 对应于一个任务进行的每一次WSAStartup（）调用，必须有一个WSACleanup（）调用.
	/* 只有最后的WSACleanup（）做实际的清除工作；前面的调用仅仅将 Windows Sockets  DLL中的内置引用计数递减.
	/* 一个简单的应用程序为确保WSACleanup（）调用了足够的次数，可以在一个循环中不断调用WSACleanup（）直至返回 WSANOTINITIALISED.    
	/* 返回 0 操作成功. 否则 SOCKET_ERROR, 同时可以调用WSAGetLastError（）获得错误代码
	************************************************************************/
	WSACleanup();
#endif
}

bool Socket::create(SocketType socketType) 
{
	/************************************************************************/
	/* socket 成功就返回新创建的套接字的描述符，如果失败就返回INVALID_SOCKET  ,Linux下失败返回-1                                                                  */
	/************************************************************************/
	m_socketType = socketType;
	if (m_socketType == Socket::SocketTypeTcp)
	{
		m_socket = socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
	}
	else if (m_socketType == Socket::SocketTypeUdp)
	{
		m_socket = socket(AF_INET,SOCK_DGRAM,IPPROTO_UDP);
	}

	if (m_socket == INVALID_SOCKET)
	{
		translateSocketError();
		return false;
	}
	else
	{
		return true;
	}
}

bool Socket::connect(SocketAddr* addr, int32 timeout) 
{
	m_socketAddr = addr;
	/************************************************************************/
	/* 成功则返回0，失败返回-1，错误码GetLastError()。                                                                     */
	/************************************************************************/
	if (isSocketValid() == false)
		return false;

	if (timeout <= 0)
	{
		if (::connect(m_socket,(struct sockaddr*)m_socketAddr->getAddr(),addr->getAddrLenght()) != 0)
		{
			translateSocketError();
			return false;
		}
	}
	else
	{
		//保存原来阻塞模式状态
		bool blocking = isBlocking();
		//需要设置成非阻塞模式才能实现超时
		setBlocking(false);

		//有可能直接返回了，一般客户端服务器端在同一台主机中才可能发生
		if (::connect(m_socket,(struct sockaddr*)m_socketAddr->getAddr(),addr->getAddrLenght()) == 0)
		{
			setBlocking(blocking);
			return true;
		}
		else
		{
			translateSocketError();
			//((e) ==  WSAEWOULDBLOCK || (e) == WSAEINTR || (e) == WSAEINPROGRESS || (e)= WSAEINVAL
			if (getSocketError() != SocketEinprogress && getSocketError() != SocketEwouldblock)
			{
				setBlocking(blocking);
				return false;
			}
		}

		fd_set fdRead,fdWrite;
		FD_ZERO(&fdRead);
		FD_ZERO(&fdWrite);

		FD_SET(m_socket,&fdRead);
		FD_SET(m_socket,&fdWrite);

		struct timeval tv;
		tv.tv_sec = timeout;
		tv.tv_usec = 0;
		int num = ::SELECT(m_socket+1,&fdRead,&fdWrite,NULL,&tv);
		//返回 0 超时
		if (num == 0)
		{
			translateSocketError();
			setBlocking(blocking);
			return false;
		}

		//如果描述符可读或可写，可能是链接成功了，或者出错了，所以要检查错误
		if (FD_ISSET(m_socket,&fdRead) || FD_ISSET(m_socket,&fdWrite))
		{
			int error = 0;
			int len = sizeof(error);
			GETSOCKOPT(m_socket,SOL_SOCKET,SO_ERROR,&error,&len);
			if (error != 0)
			{
				errno = error;
				translateSocketError();
				setBlocking(blocking);
				return false;
			}
		}
		setBlocking(blocking);
	}

	return true;
}

int Socket::send(const char* buf,int32 len, int flag)
{
	return ::send(m_socket,buf,len,flag);
}

int Socket::recv(char* buf,int32 len, int flag)
{
	return ::recv(m_socket,buf,len,flag);
}

int Socket::select(SocketSelectEvent event,int32 timeMillis)
{
	struct timeval timeout;
	timeout.tv_sec = timeMillis/1000;
	timeout.tv_usec = timeMillis%1000;
	//tv.tv_usec = (iTimeout % 1000) * 1000;

	fd_set	readfds;
	fd_set	writefds;
	fd_set	exceptfds;

	FD_ZERO(&readfds);
	FD_ZERO(&writefds);
	FD_ZERO(&exceptfds);

	if (event & SocketSelectEventRead)
	{
		FD_SET(m_socket,&readfds);
	}
	if (event & SocketSelectEventWrite)
	{
		FD_SET(m_socket,&writefds);
	}
	if (event & SocketSelectEventExcept)
	{
		FD_SET(m_socket,&exceptfds);
	}

	//返回 0 超时, 小于0 出错了，大于0 返回活动的描述符
	int num = ::SELECT(m_socket+1, &readfds, &writefds, &exceptfds, timeMillis > 0 ? &timeout : NULL); 
	if (num > 0)
	{
		if (event & SocketSelectEventRead)
		{

		}
	}
	else 
	{
		translateSocketError();
		//setSocketError(Socket::SocketTimedout);
	}
	return 0;
}

void Socket::close()
{
	::CLOSE(m_socket);
}

bool Socket::setBlocking(bool blocking)
{
	if (m_blocking == blocking)
	{
		return true;
	}

#if defined WIN32 || defined WINDING
	unsigned long block = blocking ? 0 : 1;
	/************************************************************************/
	/* 成功后，ioctlsocket()返回0。否则的话，返回SOCKET_ERROR错误，应用程序可通过WSAGetLastError()获取相应错误代码。                                                                     */
	/************************************************************************/
	if (ioctlsocket(m_socket,FIONBIO,&block)==0)
	{
		m_blocking = blocking;
		return true;
	}
#else
	unsigned int flag = fcntl(m_socket,F_GETFL,0);
	if (blocking)
		flag &=~O_NONBLOCK;
	else 
		flag |= O_NONBLOCK;

	if (fcntl(m_socket,F_SETFL,flag)!=-1)
	{
		m_blocking = blocking;
		return true;
	}
#endif
	return false;
}

bool Socket::isBlocking()
{
	return m_blocking;
}

bool Socket::setNoDelay(bool flag)
{
	int32 val = flag ? 1 : 0;
	return setOption(TCP_NODELAY, (&val), sizeof(val), IPPROTO_TCP);
}

bool Socket::isNoDelay()
{
	int32 val = 0;
	int32 len = sizeof(val);
	getOption(TCP_NODELAY,(&val),len,IPPROTO_TCP);
	return val != 0;
}

bool Socket::setLinger(bool on, int seconds)
{
	struct linger xLin;
	xLin.l_onoff  = on ? 1 : 0;
	xLin.l_linger = seconds;
	return setOption(SO_LINGER, &xLin, sizeof(xLin), SOL_SOCKET);
}

bool Socket::getLinger(bool& on, int& seconds)
{
	struct linger xLin;
	int32 iLen = sizeof(xLin);
	getOption(SO_LINGER, &xLin, iLen,SOL_SOCKET);
	on      = xLin.l_onoff != 0;
	seconds = xLin.l_linger;
	return true;
}

bool Socket::setOption(int optName,void* optVal,int optLen,int level)
{
	if (isSocketValid())
	{
		//setsockopt(m_socket,level,optName,optVal,optLen);
		SETSOCKOPT(m_socket,level,optName,optVal,optLen);
		return true;
	} else {
		return false;
	}
}

bool Socket::getOption(int optName,void* optVal,int& optLen,int level)
{
	if (isSocketValid())
	{
		GETSOCKOPT(m_socket,level,optName,optVal,&optLen);
		return true;
	} else {
		return false;
	}
}

void Socket::translateSocketError()
{
#if defined(_LINUX) || defined(_DARWIN)
	switch (errno)
	{
	case EXIT_SUCCESS:
		setSocketError(Socket::SocketSuccess);
		break;
	case ENOTCONN:
		setSocketError(Socket::SocketNotconnected);
		break;
	case ENOTSOCK:
	case EBADF:
	case EACCES:
	case EAFNOSUPPORT:
	case EMFILE:
	case ENFILE:
	case ENOBUFS:
	case ENOMEM:
	case EPROTONOSUPPORT:
		setSocketError(Socket::SocketInvalidSocket);
		break;
	case ECONNREFUSED :
		setSocketError(Socket::SocketConnectionRefused);
		break;
	case ETIMEDOUT:
		setSocketError(Socket::SocketTimedout);
		break;
	case EINPROGRESS:
		setSocketError(Socket::SocketEinprogress);
		break;
	case EWOULDBLOCK:
		//case EAGAIN:
		setSocketError(Socket::SocketEwouldblock);
		break;
	case EINTR:
		setSocketError(Socket::SocketInterrupted);
		break;
	case ECONNABORTED:
		setSocketError(Socket::SocketConnectionAborted);
		break;
	case EINVAL:
	case EPROTO:
		setSocketError(Socket::SocketProtocolError);
		break;
	case EPERM:
		setSocketError(Socket::SocketFirewallError);
		break;
	case EFAULT:
		setSocketError(Socket::SocketInvalidSocketBuffer);
		break;
	case ECONNRESET:
		setSocketError(Socket::SocketConnectionReset);
		break;
	case ENOPROTOOPT:
		setSocketError(Socket::SocketConnectionReset);
		break;
	default:
		setSocketError(Socket::SocketEunknown);
		break;
	}
#endif
#ifdef WIN32
	int32 nError = WSAGetLastError();
	switch (nError)
	{
	case EXIT_SUCCESS:
		setSocketError(Socket::SocketSuccess);
		break;
	case WSAEBADF:
	case WSAENOTCONN:
		setSocketError(Socket::SocketNotconnected);
		break;
	case WSAEINTR:
		setSocketError(Socket::SocketInterrupted);
		break;
	case WSAEACCES:
	case WSAEAFNOSUPPORT:
	case WSAEINVAL:
	case WSAEMFILE:
	case WSAENOBUFS:
	case WSAEPROTONOSUPPORT:
		setSocketError(Socket::SocketInvalidSocket);
		break;
	case WSAECONNREFUSED :
		setSocketError(Socket::SocketConnectionRefused);
		break;
	case WSAETIMEDOUT:
		setSocketError(Socket::SocketTimedout);
		break;
	case WSAEINPROGRESS:
		setSocketError(Socket::SocketEinprogress);
		break;
	case WSAECONNABORTED:
		setSocketError(Socket::SocketConnectionAborted);
		break;
	case WSAEWOULDBLOCK:
		setSocketError(Socket::SocketEwouldblock);
		break;
	case WSAENOTSOCK:
		setSocketError(Socket::SocketInvalidSocket);
		break;
	case WSAECONNRESET:
		setSocketError(Socket::SocketConnectionReset);
		break;
	case WSANO_DATA:
		setSocketError(Socket::SocketInvalidAddress);
		break;
	case WSAEADDRINUSE:
		setSocketError(Socket::SocketAddressInUse);
		break;
	case WSAEFAULT:
		setSocketError(Socket::SocketInvalidPointer);
		break;
	case WSANOTINITIALISED:
		setSocketError(Socket::SocketNotInitialised);
		break;
	default:
		setSocketError(Socket::SocketEunknown);
		break;
	}
#endif
}



