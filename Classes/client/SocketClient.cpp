#include <thread>
#include <mutex>
#include <queue>
#include <signal.h>
#include <errno.h>

#include "client/SocketClient.h"
#include "protocol/OprateMap.h"

#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/io/zero_copy_stream_impl_lite.h>
#include "utils/Util.h"

USING_NS_CC;
using namespace com::qiyi::forever::master::protobuf;

SocketClient::SocketClient()
{
	initOprateMap();
	this->_socket = nullptr;
	this->_sendThread = nullptr;
	this->_recvThread = nullptr;
	this->startScheduler();
}

SocketClient::~SocketClient()
{
	CCLOG("SocketClient destroyed");
	this->stopScheduler();

	if (_sendThread)
	{
		delete _sendThread;
		_sendThread = nullptr;
	}

	if (_recvThread)
	{
		delete _recvThread;
		_recvThread = nullptr;
	}

	if (_socket)
	{
		delete _socket;
		_socket = nullptr;
	}
}

SocketClient* SocketClient::createSocketClient(std::string ip,int port,Socket::SocketType type)
{
	SocketClient* socketClient = new SocketClient();
	socketClient->_ip = ip;
	socketClient->_port = port;
	socketClient->_type = type;
	socketClient->_connected = false;

	Socket* socket = new Socket();
	if (socket->create(type))
	{
		socketClient->_socket = socket;
		socketClient->autorelease();
		return socketClient;
	}
	else
	{
		CCLOG("create SocketClient failed");
	}

	CC_SAFE_DELETE(socketClient);
	return nullptr;
}

bool SocketClient::connect(int32 timeout)
{
	if (_connected)
	{
		return true;
	}

	_connected = _socket->connect(new SocketAddr(_ip,_port),timeout);
	if (_connected)
	{
		this->_sendThread = new MessageSendThread(_socket);
		this->_sendThread->start();
		this->_recvThread = new MessageRecvThread(_socket);
		this->_recvThread->start();	
	}
	else
	{
		CCLOG("connect failed errorCode %d ",_socket->getSocketError());
	}

	return _connected;
}

bool SocketClient::disconnect()
{
	if (_connected)
	{
		_socket->close();
	}
	_connected = false;
	return true;
}

bool SocketClient::isConnected()
{
	return _connected;
}

void SocketClient::send(ProtobufMessage* message)
{
	if (!_connected)
	{
		return;
	}
	_sendThread->enqueue(message);
}

void SocketClient::update(float time)
{
	if (!_connected)
	{
		return;
	}

	ProtobufMessage* message = _recvThread->popMessage();
	if (message)
	{
		int type = message->GetDescriptor()->FindFieldByNumber(1)->number();
		_callbacks[type](message);
		delete message;
	}
}

void SocketClient::registCallback(int type,DispatchFunc func)
{
	_callbacks[type] = func;
}

void SocketClient::startScheduler()
{
	Director::getInstance()->getScheduler()->scheduleUpdateForTarget(this,0,false);
}

void SocketClient::stopScheduler()
{
	Director::getInstance()->getScheduler()->unscheduleUpdateForTarget(this);
}

/*****************      发送线程      **************** */
MessageSendThread::MessageSendThread(Socket* socket) :
	_socket(socket),_stop(false)
{
	_messageQueue = new std::list<ProtobufMessage*>();
	_sendBuf = new char[SEND_BUF_SIZE];
}

MessageSendThread::~MessageSendThread()
{
	this->stop();

	if (_threadInstance->joinable())
	{
		_threadInstance->join();
	}

	CC_SAFE_DELETE_ARRAY(_sendBuf);
	CC_SAFE_DELETE(_threadInstance);
	CC_SAFE_DELETE(_messageQueue);
}

void MessageSendThread::start()
{
	_threadInstance = new std::thread(&MessageSendThread::threadFunc,this);
}

void MessageSendThread::threadFunc()
{
	while (!_stop)
	{
		std::lock_guard<std::mutex> lk(_mutex);
		if (!_messageQueue->empty())
		{
			ProtobufMessage* msg = *(_messageQueue->begin());
			_messageQueue->pop_front();
			this->doSend(msg);
			delete msg;
		}
		else
		{
			std::this_thread::sleep_for(std::chrono::milliseconds(50));
		}		
	}
}

void MessageSendThread::stop()
{
	_stop = true;
}

void MessageSendThread::enqueue(ProtobufMessage* message)
{
	std::lock_guard<std::mutex> lk(_mutex);
	_messageQueue->push_back(message);
}

void MessageSendThread::doSend(ProtobufMessage* message)
{
	using namespace google::protobuf;

	int opt = message->GetDescriptor()->FindFieldByName("opt")->default_value_enum()->number();

	int typeLength = Util::computeRawVarint32Size(opt);

	int msgLength = message->ByteSize();

	int headLeght = Util::computeRawVarint32Size(msgLength);

	int dataLenght = headLeght + typeLength + msgLength;
	CCLOG("MessageSendThread send data lenght %d",dataLenght);

	io::ArrayOutputStream arrayOutStream(_sendBuf, dataLenght);
	io::CodedOutputStream codedOutputStream(&arrayOutStream);
	codedOutputStream.WriteVarint32(msgLength + typeLength);	//先写入消息长度，消息长度为消息内容的长度和操作类型的长度
	codedOutputStream.WriteVarint32(opt);						//再写入操作类型

	message->SerializePartialToCodedStream(&codedOutputStream);	//最后将消息内容序列化到stream中

	_socket->send(_sendBuf,dataLenght);
}

/*****************      接收线程      **************** */
MessageRecvThread::MessageRecvThread(Socket* socket):
	_socket(socket)
{
	_messageQueue = new std::list<ProtobufMessage*>();
	_recvBuf = new char[RECV_BUF_SIZE];
}

MessageRecvThread::~MessageRecvThread()
{
	if (_threadInstance->joinable())
	{
		_threadInstance->join();
	}

	CC_SAFE_DELETE_ARRAY(_recvBuf);
	CC_SAFE_DELETE(_messageQueue);
	CC_SAFE_DELETE(_threadInstance);
}

void MessageRecvThread::start()
{
	_threadInstance = new std::thread(&MessageRecvThread::threadFunc,this);
}

void MessageRecvThread::threadFunc()
{
	using namespace google::protobuf;

	/* 缓冲区读取位置索引 **/
	int bufReadIndex = 0;

	/* 缓冲区写入位置索引 **/
	int bufWriteIndex = 0;

	int received = -1;
	do 
	{
		//当偏移已经快到缓冲区末端的时候，把缓存区末端的数据复制到最前面，同时重置receiveOffset
		if (bufWriteIndex >= RECV_BUF_SIZE - 4)
		{
			char* src = _recvBuf + bufReadIndex;
			memcpy(_recvBuf,src,bufWriteIndex - bufReadIndex);
			CCLOG("receiveOffset is almost to the tail, copy the tail data to head. bufWriteIndex %d",bufWriteIndex);
			bufWriteIndex = bufWriteIndex - bufReadIndex;
			bufReadIndex = 0;
		}
		int maxRecvLen = RECV_BUF_SIZE - bufWriteIndex;
		
		received = _socket->recv(_recvBuf + bufWriteIndex,maxRecvLen);
		if (received < 0)
		{
			CCLOG("MessageRecvThread socket error %d",_socket->getSocketError());
			break;
		}

		if (received == 0)
		{
			CCLOG("MessageRecvThread socket closed");
			break;
		}
		bufWriteIndex += received;
		CCLOG("MessageRecvThread reciced size %d  bufWriteIndex %d bufReadIndex %d",received,bufWriteIndex,bufReadIndex);
		while (bufReadIndex < bufWriteIndex)
		{
			io::ArrayInputStream arrayInputStream(_recvBuf + bufReadIndex,bufWriteIndex - bufReadIndex);
			io::CodedInputStream codedInputStream(&arrayInputStream);

			google::protobuf::uint32 bodyLength = 0;
			if (!codedInputStream.ReadVarint32(&bodyLength))
			{
				CCLOG("read length failed...");
				break;
			}
			CCLOG("MessageRecvThread bodyLength %d",bodyLength);
			int bodyLengthVarint32 = Util::computeRawVarint32Size(bodyLength);
			bufReadIndex += bodyLengthVarint32;

			google::protobuf::uint32 requestOpt = 0;
			if (!codedInputStream.ReadVarint32(&requestOpt))
			{
				CCLOG("read type failed...");
				bufReadIndex -= bodyLengthVarint32;
				break;
			}
			CCLOG("MessageRecvThread requestOpt %d",requestOpt);
			int requestOptVarint32 = Util::computeRawVarint32Size(requestOpt);
			bufReadIndex += requestOptVarint32;

			int msgLength = bodyLength - requestOptVarint32;
			CCLOG("MessageRecvThread msgLength %d",msgLength);		
			if (bufWriteIndex - bufReadIndex < msgLength)
			{
				CCLOG("MessageRecvThread buf left size is not enought for one message msgLength %d bufWriteIndex %d bufReadIndex %d headlen %d",msgLength,bufWriteIndex,bufReadIndex,(bodyLengthVarint32 + requestOptVarint32));
				bufReadIndex -= (bodyLengthVarint32 + requestOptVarint32);
				break;
			}

			std::string typeName = typeNameMap[requestOpt];
			const Descriptor* descriptor = DescriptorPool::generated_pool()->FindMessageTypeByName(typeName);
			if (!descriptor)
			{
				CCLOG("no message found typeName %s",typeName.c_str());
				return;
			}

			const Message* prototype = MessageFactory::generated_factory()->GetPrototype(descriptor);
			ProtobufMessage* message = dynamic_cast<ProtobufMessage*>(prototype->New());
			message->ParseFromArray(_recvBuf + bufReadIndex,msgLength);
			bufReadIndex += msgLength;
			
			std::lock_guard<std::mutex> lk(_mutex);
			_messageQueue->push_back(message);
			CCLOG("a complete message bufReadIndex: %d received %d messageQueue size %d",bufReadIndex,received,_messageQueue->size());
		}
	} while (received > 0);
}

ProtobufMessage* MessageRecvThread::popMessage()
{
	std::lock_guard<std::mutex> lk(_mutex);
	if (!_messageQueue->empty())
	{
		ProtobufMessage* message = *(_messageQueue->begin());
		_messageQueue->pop_front();
		return message;
	}
	else
	{
		return NULL;
	}
}

