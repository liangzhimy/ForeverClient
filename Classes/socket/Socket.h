#ifndef _SOCKET_H_
#define _SOCKET_H_

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>

#if defined(_LINUX) || defined (_DARWIN)
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netinet/tcp.h>
#include <netinet/ip.h>
#include <netdb.h>
#include <sys/uio.h>
#include <unistd.h>
#include <fcntl.h>
#endif

#if defined WIN32 || defined _WINDOWS
#include <winsock2.h>
#include <Ws2tcpip.h>
#endif

#if defined(_LINUX) || defined(_DARWIN)
typedef int					SOCKET;
#define INVALID_SOCKET		-1
#define GETSOCKOPT(a,b,c,d,e)  getsockopt(a,b,c,(void *)d, (int *)e)
#define SETSOCKOPT(a,b,c,d,e)  setsockopt(a,b,c,(const void *)d, (int)e)
#define SELECT(a,b,c,d,e)      select(a,b,c,d,e)
#define CLOSE(a)               close(a)
#endif

#if defined WIN32 || defined _WINDOWS
#define GETSOCKOPT(a,b,c,d,e)  getsockopt((int)a,(int)b,(int)c,(char *)d,(socklen_t *)e)
#define SETSOCKOPT(a,b,c,d,e)  setsockopt((int)a,(int)b,(int)c,(const char *)d,(int)e)
#define SELECT(a,b,c,d,e)      select(0,b,c,d,e)
#define CLOSE(a)               closesocket(a)
#endif

#include "socket/SocketMacros.h"
#include "socket/SocketAddr.h"

class Socket{

public:
 
	enum SocketType
	{
		SocketTypeTcp,
		SocketTypeUdp,
	};
	enum SocketSelectEvent
	{
		SocketSelectEventRead   = 0x01,
		SocketSelectEventWrite  = 0x02,
		SocketSelectEventExcept = 0x04,
		SocketSelectEventAll    = (SocketSelectEventRead | SocketSelectEventWrite | SocketSelectEventExcept),
	};
	enum SocketError
	{
		SocketGenericError = -1,          ///< Generic socket error translates to error below.
		SocketSuccess = 0,         ///< No socket error.
		SocketInvalidSocket,       ///< Invalid socket handle.
		SocketInvalidAddress,      ///< Invalid destination address specified.
		SocketInvalidPort,         ///< Invalid destination port specified.
		SocketConnectionRefused,   ///< No server is listening at remote address.
		SocketTimedout,            ///< Timed out while attempting operation.
		SocketEwouldblock,         ///< Operation would block if socket were blocking.
		SocketNotconnected,        ///< Currently not connected.
		SocketEinprogress,         ///< Socket is non-blocking and the connection cannot be completed immediately
		SocketInterrupted,         ///< Call was interrupted by a signal that was caught before a valid connection arrived.
		SocketConnectionAborted,   ///< The connection has been aborted.
		SocketProtocolError,       ///< Invalid protocol for operation.
		SocketFirewallError,       ///< Firewall rules forbid connection.
		SocketInvalidSocketBuffer, ///< The receive buffer point outside the process's address space.
		SocketConnectionReset,     ///< Connection was forcibly closed by the remote host.
		SocketAddressInUse,        ///< Address already in use.
		SocketInvalidPointer,      ///< Pointer type supplied as argument is invalid.
		SocketNotInitialised,      ///< in windows,please call WSAStartup
		SocketEunknown             ///< Unknown error please report to mark@carrierlabs.com
	};

    Socket();

    ~Socket();

    bool create(SocketType socketType);

	/**
	* 连接到指定地址，
	* timeout = 0 且  blocking == false 时，连接为非阻塞连接，会马上返回
	* timeout = 0 且  blocking == true  时，连接非阻塞连接，直到连接成功或出错才返回
	* timeout > 0 为带超时的连接，内部用 select 实现
	*/
	bool connect(SocketAddr* addr,int32 timeout = 0);
	
	/**
	* 返回值：成功返回写入的字节数，出错返回-1并设置errno
    */
	int send(const char* buf,int32 len,int flag = 0);

	/**
	* flag:
	* MSG_DONTROUTE：不查找路由表
	* MSG_OOB：接受或发送带外数据
	* MSG_PEEK：查看数据,并不从系统缓冲区移走数据
	* MSG_WAITALL ：等待任何数据
	* 
	* 返回成功读取的字节数， 0：socket closed， <0：socket error
	*/
	int recv(char* buf,int32 len,int flag = 0);
	
	/**
	* select()调用返回处于就绪状态并且已经包含在fd_set结构中的描述字总数；如果超时则返回0；否则的话，返回SOCKET_ERROR错误
	* 当返回位-1时，所有描述符集清0。
	* 当返回为0时，超时不修改任何描述符集。
	* 当返回为非0时，在3个描述符集里，依旧是1的位就是准备好的描述符。这也就是为什么，每次用select后都要用FD_ISSET的原因
	*/
	int select(SocketSelectEvent event,int32 timeMillis);
	
	int select(int32 timeMillis)
	{
		select(SocketSelectEventAll,timeMillis);
	}

	int select() 
	{
		select(SocketSelectEventAll,0);
	};

	/**
	* close操作只是使相应socket描述字的引用计数-1，只有当引用计数为0的时候，才会触发TCP客户端向服务器发送终止连接请求
	*/
	void close();

	bool setBlocking(bool blocking = true);
	bool isBlocking();

	bool setNoDelay(bool flag);
	bool isNoDelay();
	
	/**
	* on == false,忽略: 
	* on == true seconds == 0 ，close时马上返回，但不会发送未发送完成的数据，而是通过一个REST包强制的关闭socket描述符，也就是强制的退出    
	* on == true seconds > 0 ， close时不会马上返回，内核会延迟一段时间，这个时间就由l_linger得值来决定。
	*							 如果超时时间到达之前，发送完未发送的数据(包括FIN包)并得到另一端的确认，closesocket会返回正确，socket描述符优雅性退出。
	*							 否则，closesocket会直接返回错误值，未发送数据丢失，socket描述符被强制性退出。
	*							 需要注意的时，如果socket描述符被设置为非堵塞型，则closesocket会直接返回值。 
	*/
	bool setLinger(bool on, int seconds);
	bool getLinger(bool& on, int& seconds);

	bool setOption(int optName, void* optVal, int optLen, int level = SOL_SOCKET);
	bool getOption(int optName, void* optVal, int& optLen, int level = SOL_SOCKET);

	virtual bool isSocketValid(void) { return (m_socket != INVALID_SOCKET);}
	SocketError getSocketError(){return m_socketErrno;}
private:
	void setSocketError(SocketError error) {m_socketErrno = error;}
	void translateSocketError();

private:
	SOCKET				m_socket;
	SocketAddr*			m_socketAddr;
	SocketType			m_socketType;
	SocketError			m_socketErrno;
	bool				m_blocking;
#if defined _WIN32 || defined WINDOWS
	WSADATA				m_hWSAData;
#endif
};

#endif
