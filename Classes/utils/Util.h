#ifndef __UTIL_H__
#define __UTIL_H__

#include "AppMacros.h"
#include "CCStdC.h"

class Util
{
public:
	/**
	* ����32λ����ʵ����Ҫ���ٸ��ֽڴ洢��
	* ��Ҫ�Ǹ� google protobuf��
	*/
    static int computeRawVarint32Size(int value)
	{
		int typeLength = 1;
		if ((value & (0xffffffff <<  7)) == 0) typeLength =  1;
		else if ((value & (0xffffffff << 14)) == 0) typeLength =  2;
		else if ((value & (0xffffffff << 21)) == 0) typeLength =  3;
		else if ((value & (0xffffffff << 28)) == 0) typeLength =  4;
		return typeLength;
	}

	/**
	* �ĸ��ֽ�ת��32λ����
	*/
	static int bytes2Int(byte* bytes)
	{
		int addr = bytes[0] & 0xFF;
		addr |= ((bytes[1] << 8) & 0xFF00);
		addr |= ((bytes[2] << 16) & 0xFF0000);
		addr |= ((bytes[3] << 24) & 0xFF000000);
		return addr;
	}

	/**
	* 32λ����ת���ֽ�����
	*/
	static void int2Byte(int u, byte* out)
	{
		out[0] = (byte)(u);
		out[1] = (byte)(u >> 8);
		out[2] = (byte)(u >> 16);
		out[3] = (byte)(u >> 24);
	}

	/**
	* ��õ�ǰʱ�䣬��Ϊ��λ
	*/
	static long getCurrentTimeSec()
	{
		struct timeval t;
		cocos2d::gettimeofday(&t, NULL);
		return t.tv_sec;
	}

	/**
	* ��õ�ǰʱ�䣬���뵥λ
	*/
	static long getCurrentTimeUSec()
	{
		struct timeval t;
		cocos2d::gettimeofday(&t, NULL);
		return t.tv_sec * 1000000 + t.tv_usec;
	}
};

#endif // __UTIL_H__
