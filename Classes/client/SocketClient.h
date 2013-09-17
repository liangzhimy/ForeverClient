#ifndef __SOCKET_CLIENT_H__
#define __SOCKET_CLIENT_H__

#include "cocos2d.h"
#include "socket/Socket.h"
#include "protocol/GameProtocol.pb.h"

typedef google::protobuf::Message ProtobufMessage;
typedef std::function<void(ProtobufMessage*)> DispatchFunc;

class MessageRecvThread;
class MessageSendThread;

#define SEND_BUF_SIZE 1024
#define RECV_BUF_SIZE 1024 * 1024

class Callback
{
public:
	virtual ~Callback() {};
	virtual void onMessage(google::protobuf::Message* message) const = 0;
};

template <typename T>
class CallbackT : public Callback
{
public:
	typedef std::function<void (T* message)> ProtobufMessageCallback;

	CallbackT(const ProtobufMessageCallback& callback)
		: callback_(callback)
	{
	}

	virtual void onMessage(google::protobuf::Message* message) const
	{
		T* t = dynamic_cast<T*>(message);
		assert(t != NULL);
		callback_(t);
	}

private:
	ProtobufMessageCallback callback_;
};

/**
* Socket�ͻ��ˣ�����������Ϣ��������Ϣ
* ������Ϣ���ڷ����߳��У�
* ������Ϣ
*/
class SocketClient : public cocos2d::Object
{
public:

	/**
	* ����һ��socket�ͻ��ˣ�Ĭ��ΪTCP
	*/
	static SocketClient*	createSocketClient(std::string ip,int port,Socket::SocketType type = Socket::SocketTypeTcp);
public:

	/**
	* ���ӵ�socket
	*/
	bool connect(int32 timeout = 0);

	/**
	* �Ͽ�����
	*/
	bool disconnect();

	/**
	* �жϴ˿ͻ��������Ƿ���
	*/
	bool isConnected();

	/**
	* ������Ϣ
	*/
	void send(ProtobufMessage* message);

	/**
	* ע��ص�����
	*/
	void registCallback(int type,DispatchFunc func);

	template<typename T>
	void registCallbackT(int type,const typename CallbackT<T>::ProtobufMessageCallback& callback)
	{
		_callbacksT[type] = new CallbackT<T>(callback);
	}
private:
	SocketClient();
	virtual ~SocketClient();

	/**
	* Object�еĶ�ʱ��������û֡������ã���������Ƿ����µ���Ϣ
	*/
	virtual void update(float time);

	void startScheduler();

	void stopScheduler();

private:
	Socket*						_socket;
	MessageSendThread*			_sendThread;
	MessageRecvThread*			_recvThread;

	std::map<int, DispatchFunc>	_callbacks;
	std::map<int, Callback*>	_callbacksT;
	std::string					_ip;
	int							_port;
	Socket::SocketType			_type;
	bool						_connected;
};

/**
* ������Ϣ�̣߳����߳���SocketClient�ɹ����Ӻ�����������������Ϣ���У������Ϊ�գ�������Ϣ������ȴ���Ϣ
*/
class MessageSendThread
{
public:
	MessageSendThread(Socket* socket);

	~MessageSendThread();

	void start();

	void stop();

	void enqueue(ProtobufMessage* message);

private:

	void threadFunc();

	/**
	* ִ�з�����Ϣ
	*/
	void doSend(google::protobuf::Message* message);

private:
	bool							_stop;
	Socket*							_socket;
	std::list<ProtobufMessage*>*	_messageQueue;
	std::mutex						_mutex;
	std::thread*					_threadInstance;
	/**
	* ����һ����̬������������Ϣ���ͣ�����ÿ�ζ������µ��ڴ�
	*/
	char*							_sendBuf;
};

/**
* ������Ϣ�̣߳����߳���SocketClient�ɹ����Ӻ�������һֱ�ȴ���Ϣ����
*/
class MessageRecvThread
{
public:
	MessageRecvThread(Socket* socket);

	~MessageRecvThread();

	void start();
	
	/**
	* �յ���Ϣ�����ص�һ����Ϣ
	*/
	ProtobufMessage* popMessage();

private:

	void threadFunc();

private:
	Socket*							_socket;
	std::list<ProtobufMessage*>*	_messageQueue;
	std::mutex						_mutex;
	std::thread*					_threadInstance;
	/**
	* ����һ����̬������������Ϣ���գ�����ÿ�ζ������µ��ڴ�
	*/
	char*							_recvBuf;
};

#endif // __SOCKET_CLIENT_H__
