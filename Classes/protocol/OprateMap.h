#ifndef _TYPE_NAME_MAP_
#define _TYPE_NAME_MAP_

#include <map>
#include "protocol/GameProtocol.pb.h"

using namespace com::qiyi::forever::master::protobuf;

std::map<int,std::string> typeNameMap;

void initOprateMap()
{
	typeNameMap[Opration::LOGIN] = "com.qiyi.forever.master.protobuf.LoginResponseMessage";
}

#endif
