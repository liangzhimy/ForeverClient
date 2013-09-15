#ifndef __APPMACROS_H__
#define __APPMACROS_H__

#include "cocos2d.h"

#define FRAME_WIDTH		960
#define FRAME_HEIGHT	540

#define DESIGN_RESOLUTION_480X320    0
#define DESIGN_RESOLUTION_1024X768   1
#define DESIGN_RESOLUTION_2048X1536  2
#define DESIGN_RESOLUTION_1280X720   3

/* If you want to switch design resolution, change next line */
#define TARGET_DESIGN_RESOLUTION_SIZE  DESIGN_RESOLUTION_1280X720


#if (TARGET_DESIGN_RESOLUTION_SIZE == DESIGN_RESOLUTION_480X320)
static cocos2d::Size designResolutionSize = cocos2d::Size(480, 320);
#elif (TARGET_DESIGN_RESOLUTION_SIZE == DESIGN_RESOLUTION_1024X768)
static cocos2d::Size designResolutionSize = cocos2d::Size(1024, 768);
#elif (TARGET_DESIGN_RESOLUTION_SIZE == DESIGN_RESOLUTION_2048X1536)
static cocos2d::Size designResolutionSize = cocos2d::Size(2048, 1536);
#elif (TARGET_DESIGN_RESOLUTION_SIZE == DESIGN_RESOLUTION_1280X720)
static cocos2d::Size designResolutionSize = cocos2d::Size(1280, 720);
#else
#error unknown target design resolution!
#endif

#endif /* __APPMACROS_H__ */
