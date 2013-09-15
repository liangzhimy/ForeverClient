#ifndef __SOCKET_MACROS_H__
#define __SOCKET_MACROS_H__

#include <limits.h>

#ifdef __cplusplus
extern "C"
{
#endif

/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Type Definition Macros                                                    */
/*                                                                           */
/*---------------------------------------------------------------------------*/
#ifndef __WORDSIZE
  /* Assume 32 */
  #define __WORDSIZE 32
#endif

#if defined(_LINUX) || defined(_DARWIN)
    typedef unsigned char  uint8;
    typedef char           int8;
    typedef unsigned short uint16;
    typedef short          int16;
    typedef unsigned int   uint32;
    typedef int            int32;
#endif

#ifdef WIN32
    struct iovec {
        void  *iov_base;
        size_t iov_len;
    };

    typedef unsigned char  uint8;
    typedef char           int8;
    typedef unsigned short uint16;
    typedef short          int16;
    typedef unsigned int   uint32;
    typedef int            int32;
#endif

#ifdef WIN32
    typedef int socklen_t;
#endif

#if defined(WIN32)
    typedef unsigned long long int uint64;
    typedef long long int          int64;
#elif (__WORDSIZE == 32)
    __extension__
    typedef long long int          int64;
    __extension__
    typedef unsigned long long int uint64;
#elif (__WORDSIZE == 64)
    typedef unsigned long int uint64;
    typedef long int          int64;
#endif

#ifdef WIN32
  #if __WORDSIZE == 64
    #define SIZE_MAX (18446744073709551615UL)
  #else
    #ifndef SIZE_MAX
    #define SIZE_MAX (4294967295U)
	#endif
  #endif
#endif

#if defined(WIN32)
  #define ssize_t size_t
#endif

#ifndef TRUE
  #define TRUE 1
#endif

#ifndef FALSE
  #define FALSE 0
#endif

#ifndef htonll
#ifdef _BIG_ENDIAN
#define htonll(x)   (x)
#define ntohll(x)   (x)
#else
#define htonll(x)   ((((uint64)htonl(x)) << 32) + htonl(x >> 32))
#define ntohll(x)   ((((uint64)ntohl(x)) << 32) + ntohl(x >> 32))
#endif
#endif

/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Socket Macros                                                             */
/*                                                                           */
/*---------------------------------------------------------------------------*/
#ifdef WIN32
#define SHUT_RD                0
#define SHUT_WR                1
#define SHUT_RDWR              2
#define ACCEPT(a,b,c)          accept(a,b,c)
#define CONNECT(a,b,c)         connect(a,b,c)

#define READ(a,b,c)            read(a,b,c)
#define RECV(a,b,c,d)          recv(a, (char *)b, c, d)
#define RECVFROM(a,b,c,d,e,f)  recvfrom(a, (char *)b, c, d, (sockaddr *)e, (int *)f)
#define RECV_FLAGS             MSG_WAITALL
#define SEND(a,b,c,d)          send(a, (const char *)b, (int)c, d)
#define SENDTO(a,b,c,d,e,f)    sendto(a, (const char *)b, (int)c, d, e, f)
#define SEND_FLAGS             0
#define SENDFILE(a,b,c,d)      sendfile(a, b, c, d)
#define SET_SOCKET_ERROR(x,y)  errno=y
#define SOCKET_ERROR_INTERUPT  EINTR
#define SOCKET_ERROR_TIMEDOUT  EAGAIN
#define WRITE(a,b,c)           write(a,b,c)
#define WRITEV(a,b,c)          Writev(b, c)
#define GETHOSTBYNAME(a)       gethostbyname((const char *)a)
#endif

#if defined(_LINUX) || defined(_DARWIN)
#define ACCEPT(a,b,c)          accept(a,b,c)
#define CONNECT(a,b,c)         connect(a,b,c)

#define READ(a,b,c)            read(a,b,c)
#define RECV(a,b,c,d)          recv(a, (void *)b, c, d)
#define RECVFROM(a,b,c,d,e,f)  recvfrom(a, (char *)b, c, d, (sockaddr *)e, f)
#define RECV_FLAGS             MSG_WAITALL
#define SEND(a,b,c,d)          send(a, (const int8 *)b, c, d)
#define SENDTO(a,b,c,d,e,f)    sendto(a, (const int8 *)b, c, d, e, f)
#define SEND_FLAGS             0
#define SENDFILE(a,b,c,d)      sendfile(a, b, c, d)
#define SET_SOCKET_ERROR(x,y)  errno=y
#define SOCKET_ERROR_INTERUPT  EINTR
#define SOCKET_ERROR_TIMEDOUT  EAGAIN
#define WRITE(a,b,c)           write(a,b,c)
#define WRITEV(a,b,c)          writev(a, b, c)
#define GETHOSTBYNAME(a)       gethostbyname((const char *)a)
#endif


/*---------------------------------------------------------------------------*/
/*                                                                           */
/* File Macros                                                               */
/*                                                                           */
/*---------------------------------------------------------------------------*/
#define STRUCT_STAT         struct stat
#define LSTAT(x,y)          lstat(x,y)
#define FILE_HANDLE         FILE *
#define CLEARERR(x)         clearerr(x)
#define FCLOSE(x)           fclose(x)
#define FEOF(x)             feof(x)
#define FERROR(x)           ferror(x)
#define FFLUSH(x)           fflush(x)
#define FILENO(s)           fileno(s)
#define FOPEN(x,y)          fopen(x, y)
//#define FREAD(a,b,c,d)      fread(a, b, c, d)
#define FSTAT(s, st)        fstat(FILENO(s), st)
//#define FWRITE(a,b,c,d)     fwrite(a, b, c, d)
#define STAT_BLK_SIZE(x)    ((x).st_blksize)


/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Misc Macros                                                               */
/*                                                                           */
/*---------------------------------------------------------------------------*/
#if defined(WIN32)
  #define GET_CLOCK_COUNT(x) QueryPerformanceCounter((LARGE_INTEGER *)x)
#else
  #define GET_CLOCK_COUNT(x) gettimeofday(x, NULL)
#endif

#if defined(WIN32)
  #define STRTOULL(x) _atoi64(x)
#else
  #define STRTOULL(x) strtoull(x, NULL, 10)
#endif

#if defined(WIN32)
  #define SNPRINTF _snprintf
  #define PRINTF   printf
  #define VPRINTF  vprintf
  #define FPRINTF  fprintf
#else 
  #define SNPRINTF snprintf
  #define PRINTF   printf
  #define VPRINTF  vprintf
  #define FPRINTF  fprintf
#endif

#ifdef __cplusplus
}
#endif

#endif /* __SOCKET_MACROS_H__ */
