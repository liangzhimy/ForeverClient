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
	* ���ӵ�ָ����ַ��
	* timeout = 0 ��  blocking == false ʱ������Ϊ���������ӣ������Ϸ���
	* timeout = 0 ��  blocking == true  ʱ�����ӷ��������ӣ�ֱ�����ӳɹ������ŷ���
	* timeout > 0 Ϊ����ʱ�����ӣ��ڲ��� select ʵ��
	*/
	bool connect(SocketAddr* addr,int32 timeout = 0);
	
	/**
	* ����ֵ���ɹ�����д����ֽ�����������-1������errno
    */
	int send(const char* buf,int32 len,int flag = 0);

	/**
	* flag:
	* MSG_DONTROUTE��������·�ɱ�
	* MSG_OOB�����ܻ��ʹ�������
	* MSG_PEEK���鿴����,������ϵͳ��������������
	* MSG_WAITALL ���ȴ��κ�����
	* 
	* ���سɹ���ȡ���ֽ����� 0��socket closed�� <0��socket error
	*/
	int recv(char* buf,int32 len,int flag = 0);
	
	/**
	* select()���÷��ش��ھ���״̬�����Ѿ�������fd_set�ṹ�е������������������ʱ�򷵻�0������Ļ�������SOCKET_ERROR����
	* ������λ-1ʱ����������������0��
	* ������Ϊ0ʱ����ʱ���޸��κ�����������
	* ������Ϊ��0ʱ����3�����������������1��λ����׼���õ�����������Ҳ����Ϊʲô��ÿ����select��Ҫ��FD_ISSET��ԭ��
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
	* close����ֻ��ʹ��Ӧsocket�����ֵ����ü���-1��ֻ�е����ü���Ϊ0��ʱ�򣬲Żᴥ��TCP�ͻ����������������ֹ��������
	*/
	void close();

	bool setBlocking(bool blocking = true);
	bool isBlocking();

	bool setNoDelay(bool flag);
	bool isNoDelay();
	
	/**
	* on == false,����: 
	* on == true seconds == 0 ��closeʱ���Ϸ��أ������ᷢ��δ������ɵ����ݣ�����ͨ��һ��REST��ǿ�ƵĹر�socket��������Ҳ����ǿ�Ƶ��˳�    
	* on == true seconds > 0 �� closeʱ�������Ϸ��أ��ں˻��ӳ�һ��ʱ�䣬���ʱ�����l_linger��ֵ��������
	*							 �����ʱʱ�䵽��֮ǰ��������δ���͵�����(����FIN��)���õ���һ�˵�ȷ�ϣ�closesocket�᷵����ȷ��socket�������������˳���
	*							 ����closesocket��ֱ�ӷ��ش���ֵ��δ�������ݶ�ʧ��socket��������ǿ�����˳���
	*							 ��Ҫע���ʱ�����socket������������Ϊ�Ƕ����ͣ���closesocket��ֱ�ӷ���ֵ�� 
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
