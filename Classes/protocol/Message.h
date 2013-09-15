#ifndef _GAME_MESSAGE_H_
#define _GAME_MESSAGE_H_

#include <string>
#include <google/protobuf/message.h>

enum MSG_TYPE{
	MSG_TYPE_LOGIN_REQUEST	= 1, 
	MSG_TYPE_LOGIN_RESPONSE	= 2,
};

class Message
{
public:
	Message(google::protobuf::Message* msg,int type);
	
	virtual ~Message(void);

	const char* data();

	int size();

private:
	int							_size;
	int							_type;
	char*						_data; 
	google::protobuf::Message*	_message;
	
	static char*				SEND_DATA_BUF;
};
#endif
