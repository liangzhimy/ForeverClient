#include "main.h"
#include "../Classes/AppDelegate.h"
#include "../Classes/AppMacros.h"
#include "CCEGLView.h"
#include <thread>
#include <mutex>
#include <queue>
#include <signal.h>
#include <errno.h>
#include <iostream>
#include <thread>
#include <chrono>

USING_NS_CC;


void CreateConsole()
{
	AllocConsole();

	SetConsoleTitle(L"诸神Q传 测试控制台");

	freopen("conin$", "r+t", stdin);
	freopen("conout$", "w+t", stdout);
	freopen("conout$", "w+t", stderr);
}

void CloseConsole()
{
	fclose(stderr);
	fclose(stdout);
	fclose(stdin);

	FreeConsole();
}

int APIENTRY _tWinMain(HINSTANCE hInstance,
					   HINSTANCE hPrevInstance,
					   LPTSTR    lpCmdLine,
					   int       nCmdShow)
{
	UNREFERENCED_PARAMETER(hPrevInstance);
	UNREFERENCED_PARAMETER(lpCmdLine);

#ifdef WIN32
	//CreateConsole();
#endif

	// create the application instance
	AppDelegate app;
    EGLView eglView;
    eglView.init("TestCPP",960,640);
	return Application::getInstance()->run();
}
