#include "protocol/Message.h"
#include "protocol/GameProtocol.pb.h"
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/io/zero_copy_stream.h>
#include <google/protobuf/io/zero_copy_stream_impl_lite.h>
#include "utils/Util.h"

using namespace com::qiyi::forever::master::protobuf;

char* Message::SEND_DATA_BUF = new char[2048];

Message::Message(google::protobuf::Message* message,int type) :
	_type(type), _message(message),_size(0)
{
	char* temp = SEND_DATA_BUF;

	int typeLength = Util::computeRawVarint32Size(_type);

	int bodyLength = _message->ByteSize() + typeLength;

	int headLeght = Util::computeRawVarint32Size(bodyLength);

	int dataLenght = bodyLength + headLeght;
	_data = new char[dataLenght];

	google::protobuf::io::ZeroCopyOutputStream *raw_output = new google::protobuf::io::ArrayOutputStream(temp, dataLenght);   
	google::protobuf::io::CodedOutputStream* coded_output = new google::protobuf::io::CodedOutputStream(raw_output);
	coded_output->WriteVarint32(bodyLength);
	coded_output->WriteVarint32(_type);

	_message->SerializePartialToCodedStream(coded_output);
	_size = dataLenght;
}

Message::~Message(void)
{
	delete _message;
}

int Message::size(void)
{
	return _size;
}

const char* Message::data(void)
{
	return (const char*)SEND_DATA_BUF;
}