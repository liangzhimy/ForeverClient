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
* Socket客户端，用来发送消息，接收消息
* 发送消息会在发送线程中，
* 接收消息
*/
class SocketClient : public cocos2d::Object
{
public:

	/**
	* 创建一个socket客户端，默认为TCP
	*/
	static SocketClient*	createSocketClient(std::string ip,int port,Socket::SocketType type = Socket::SocketTypeTcp);
public:

	/**
	* 连接到socket
	*/
	bool connect(int32 timeout = 0);

	/**
	* 断开连接
	*/
	bool disconnect();

	/**
	* 判断此客户端连接是否建立
	*/
	bool isConnected();

	/**
	* 发送消息
	*/
	void send(ProtobufMessage* message);

	/**
	* 注册回调方法
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
	* Object中的定时器方法，没帧都会调用，用来检查是否有新的消息
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
* 发送消息线程，此线程随SocketClient成功连接后启动，启动后检查消息队列，如果不为空，则发送消息，否则等待消息
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
	* 执行发送消息
	*/
	void doSend(google::protobuf::Message* message);

private:
	bool							_stop;
	Socket*							_socket;
	std::list<ProtobufMessage*>*	_messageQueue;
	std::mutex						_mutex;
	std::thread*					_threadInstance;
	/**
	* 声明一个静态缓冲区用作消息发送，避免每次都分配新的内存
	*/
	char*							_sendBuf;
};

/**
* 接收消息线程，此线程随SocketClient成功连接后启动，一直等待消息到达
*/
class MessageRecvThread
{
public:
	MessageRecvThread(Socket* socket);

	~MessageRecvThread();

	void start();
	
	/**
	* 收到消息，返回第一个消息
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
	* 声明一个静态缓冲区用作消息接收，避免每次都分配新的内存
	*/
	char*							_recvBuf;
};

#endif // __SOCKET_CLIENT_H__
