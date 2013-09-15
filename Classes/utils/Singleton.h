#ifndef __Singleton_h__
#define __Singleton_h__

template<typename T> 
class Singleton
{
public:
	static T* getInstance()
	{
		if (m_Instance == NULL)
		{
			m_Instance = new T();
		}
		return m_Instance;
	}

	static T& getInstanceRef()
	{
		*getInstance();
	}

	static void destroy()
	{
		if (m_Instance)
		{
			delete m_Instance;
			m_Instance = NULL;
		}
	}

private:
	static T* m_Instance;
};

#endif