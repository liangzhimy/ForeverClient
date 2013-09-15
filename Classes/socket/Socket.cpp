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
	/* ��Ӧ��һ��������е�ÿһ��WSAStartup�������ã�������һ��WSACleanup��������.
	/* ֻ������WSACleanup������ʵ�ʵ����������ǰ��ĵ��ý����� Windows Sockets  DLL�е��������ü����ݼ�.
	/* һ���򵥵�Ӧ�ó���Ϊȷ��WSACleanup�����������㹻�Ĵ�����������һ��ѭ���в��ϵ���WSACleanup����ֱ������ WSANOTINITIALISED.    
	/* ���� 0 �����ɹ�. ���� SOCKET_ERROR, ͬʱ���Ե���WSAGetLastError������ô������
	************************************************************************/
	WSACleanup();
#endif
}

bool Socket::create(SocketType socketType) 
{
	/************************************************************************/
	/* socket �ɹ��ͷ����´������׽��ֵ������������ʧ�ܾͷ���INVALID_SOCKET  ,Linux��ʧ�ܷ���-1                                                                  */
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
	/* �ɹ��򷵻�0��ʧ�ܷ���-1��������GetLastError()��                                                                     */
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
		//����ԭ������ģʽ״̬
		bool blocking = isBlocking();
		//��Ҫ���óɷ�����ģʽ����ʵ�ֳ�ʱ
		setBlocking(false);

		//�п���ֱ�ӷ����ˣ�һ��ͻ��˷���������ͬһ̨�����вſ��ܷ���
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
		//���� 0 ��ʱ
		if (num == 0)
		{
			translateSocketError();
			setBlocking(blocking);
			return false;
		}

		//����������ɶ����д�����������ӳɹ��ˣ����߳����ˣ�����Ҫ������
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

	//���� 0 ��ʱ, С��0 �����ˣ�����0 ���ػ��������
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
	/* �ɹ���ioctlsocket()����0������Ļ�������SOCKET_ERROR����Ӧ�ó����ͨ��WSAGetLastError()��ȡ��Ӧ������롣                                                                     */
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



