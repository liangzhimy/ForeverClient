#ifndef  _LOG_H_
#define  _LOG_H_

class Log
{
	enum LOG_LEVEL
	{
		LOG_LEVEL_DEBUG,
		LOG_LEVEL_INFO,
		LOG_LEVEL_WARNNING,
		LOG_LEVEL_ERROR,
	};

public:
    static void log(LOG_LEVEL level,const char* msg);

	static void debug(const char* msg)		{log(LOG_LEVEL_DEBUG,msg);}
	static void info(const char* msg)		{log(LOG_LEVEL_INFO,msg);}
	static void warnning(const char* msg)	{log(LOG_LEVEL_WARNNING,msg);}
	static void error(const char* msg)		{log(LOG_LEVEL_ERROR,msg);}

private:
	Log();
	virtual ~Log();
};

#endif

