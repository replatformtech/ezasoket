
/* 
**  This file is part of OpenEZA aka "Open Source EZASOKET".
**
**  OpenEZA is free software: you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation, either version 3 of the License, or
**  (at your option) any later version.
**
**  OpenEZA is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with OpenEZA.  If not, see <http://www.gnu.org/licenses/>.
**
*/

#define HP

#ifdef HP
#define _XOPEN_SOURCE_EXTENDED
#define GIVESOCKET_METHOD_NONE
#else
#define GIVESOCKET_METHOD_FORK
#endif

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <signal.h>
#include <limits.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <netdb.h> 
#ifdef HP
#include <sys/ioctl.h>
#include <net/if.h>
#else
#include <asm/ioctls.h>
#include <linux/sockios.h>
#include <linux/if.h>
#endif
#include <fcntl.h>
#include <sys/un.h>
#include "srcgen/config.h"
#define EZASOKET_AF_UNSPEC (0)  
#define EZASOKET_AF_INET   (2)
#define EZASOKET_AF_INET6 (19)

#define HAVE_MSGHDR_MSG_CONTROL

/* binary* is a misnomer.  These variables could really be BINARY
** or COMP.  In addition the BINARY variables byte order
** vary by machine.
*/

/* EZASOKET requires that the calling programs be consistent in their
** use of COMP and BINARY variables passed to EZASOKET.
*/

/* -------------------------------------------
**                   Byte Order                 Swap?
**             ----------------------    -------------------
**             COMP    BINARY  COMP-5    COMP  BINARY COMP-5
** z/OSs        BE       BE      BE        -     -      -
** z/VSE        BE       BE      BE        -     -      -
** zLinux       BE       BE      BE        N     N      N
** Intel Linux  BE       BE      LE        Y     Y      N
** AIX          BE       BE      BE        N     N      N
** 
** Y - swap
** N - do not swap
** - - not applicable
** ------------------------------------------- */

typedef uint16_t binary94;
typedef uint32_t binary98;
typedef int32_t  binary98s;
typedef uint64_t binary916;
typedef char * pointer;
typedef char picX;
typedef void (*socketFunction)(binary94 *, ...);
typedef void (*voidFunction)(void);

#define LOG

#ifdef BINARY_LE
static int Swap=1;
#else
static int Swap=0;
#endif

static int PicXisEbcdic = 0;
int LooksLikeEbcdic(picX *String)
{
   /* This function looks at a picX and makes a guess as to whether it
   ** is ascii or ebcdic.  returns 1 for ebcdic and 0 for ascii.
   ** This function will have to be made more complex.
   */
   if (String[0] == 0x40)
   {
      return(1);
   }
   return(0);
}

#ifndef HP
static int PicX2char(char *Dst, picX *Src, int Size);
#endif

static char char2Hex(unsigned char c)
{
   static const char *HexCharacters = "0123456789ABCDEF";
   
   if (c > 15)
   {
      /* Here we have to outpur an error information */
   }

   return HexCharacters[c];
}

void str2picX(picX *dst, int dstlen, const char *src, int srclen)
{
   memcpy(dst, src, srclen);
   memset(&(dst[srclen]), ' ', (dstlen - srclen));
}

void int2bin94(binary94 *dst, int32_t src)
{
   if (Swap)
   {
      unsigned char srcary[2];
      unsigned char srcaryrev[2];
      memcpy(srcary, &src, 2);
      srcaryrev[0] = srcary[1];
      srcaryrev[1] = srcary[0];
      memcpy(dst, srcaryrev, 2);
   }
   else
   {
      short ssrc = (short)src;
      memcpy(dst, &ssrc, 2);
   }
}

void int2bin98(binary98 *dst, uint32_t src)
{
   if (Swap)
   {
      unsigned char srcary[4];
      unsigned char srcaryrev[4];
      memcpy(srcary, &src, 4);
      srcaryrev[0] = srcary[3];
      srcaryrev[1] = srcary[2];
      srcaryrev[2] = srcary[1];
      srcaryrev[3] = srcary[0];
      memcpy(dst, srcaryrev, 4);
   }
   else
   {
      memcpy(dst, &src, 4);
   }
}

int32_t bin942int(binary94 *src)
{
   int32_t dst = 0;
   if (Swap)
   {
      unsigned char srcary[2];
      unsigned char srcaryrev[2];
      memcpy(srcary, src, 2);
      srcaryrev[0] = srcary[1];
      srcaryrev[1] = srcary[0];
      memcpy(&dst, srcaryrev, 2);
   }
   else
   {
      int16_t sdst;
      memcpy(&sdst, src, 2);
      dst = sdst;
   }
   return(dst);
}

int32_t bin98s2int(binary98s *src)
{
   int32_t dst;
   if (Swap)
   {
      unsigned char srcary[4];
      unsigned char srcaryrev[4];
      memcpy(srcary, src, 4);
      srcaryrev[0] = srcary[3];
      srcaryrev[1] = srcary[2];
      srcaryrev[2] = srcary[1];
      srcaryrev[3] = srcary[0];
      memcpy(&dst, srcaryrev, 4);
   }
   else
   {
      memcpy(&dst, src, 4);
   }
   return(dst);
}

uint32_t bin982int(binary98 *src)
{
   uint32_t dst;
   if (Swap)
   {
      unsigned char srcary[4];
      unsigned char srcaryrev[4];
      memcpy(srcary, src, 4);
      srcaryrev[0] = srcary[3];
      srcaryrev[1] = srcary[2];
      srcaryrev[2] = srcary[1];
      srcaryrev[3] = srcary[0];
      memcpy(&dst, srcaryrev, 4);
   }
   else
   {
      memcpy(&dst, src, 4);
   }
   return(dst);
}

void int2bin98s(binary98s *dst, int32_t src)
{
   if (Swap)
   {
      unsigned char srcary[4];
      unsigned char srcaryrev[4];
      memcpy(srcary, &src, 4);
      srcaryrev[0] = srcary[3];
      srcaryrev[1] = srcary[2];
      srcaryrev[2] = srcary[1];
      srcaryrev[3] = srcary[0];
      memcpy(dst, srcaryrev, 4);
   }
   else
   {
      memcpy(dst, &src, 4);
   }
}

int listIndex(const char *Item, const char *Array[], int Length)
{
   int i = 1;
   while (Array[i])
   {
      if (!memcmp(Array[i], Item, Length))
      {
         return(i);
      }
      i++;
   }
   return(0);
}

typedef struct
{
   pointer NAME;
   pointer NAME_LEN;
   pointer IOV;
   pointer IOVCNT;
   pointer ACCRIGHTS;
   pointer ACCRLEN;
} MsgType;

typedef struct
{
   pointer  BUFFER_POINTER;
   picX     RESERVED[4];
   binary98 BUFFER_LENGTH;
} iovType;

typedef struct
{
   binary98 TIMEOUT_SECONDS;
   binary98 TIMEOUT_MICROSEC;
} TimeOut;

#ifdef OPEN_EZASOKET_IPV6

typedef struct
{
   binary916 one;
   binary916 two;
} IpAddressType;

typedef struct
{
   binary94 FAMILY;
   binary94 PORT;
   binary98 FLOW_INFO;
   IpAddressType IP_ADDRESS;
   binary98 SCOPE_ID;
} NameType;

/* The following goofy line will trigger a compile time error if
** the structure is not the correct size.
*/
char NameType_Not_Correct_Size[1 - 2*(sizeof(NameType) != 28)];

int32_t IP_ADDRESS2int(IpAddressType *ipt)
{
#error "IPV6 not supported"
}

#else

typedef binary98 IpAddressType;

typedef struct
{
   binary94 FAMILY;
   binary94 PORT;
   IpAddressType IP_ADDRESS;
   picX     RESERVED[8];
} NameType;

/* The following goofy line will trigger a compile time error if
** the structure is not the correct size.
*/
char NameType_Not_Correct_Size[1 - 2*(sizeof(NameType) != 16)];

int32_t IP_ADDRESS2int(IpAddressType *ipt)
{
   return(bin982int(ipt));
}

#endif

typedef struct
{
   picX     TCPNAME[8];
   picX     ADSNAME[8];
} IdentType;

typedef struct
{
   binary98 DOMAIN;
   picX     NAME[8];
   picX     TASK[8];
   picX     RESERVED[20];
} ClientType;

typedef struct
{
   binary98 FLAGS;
   binary98 FAMILY;
   binary98 SOCKTYPE;
   binary98 PROTOCOL;
   binary98 RESERVED1;
   binary98 RESERVED2;
   binary98 RESERVED3;
   binary98 RESERVED4;
} AddressInfoType;

/* optional structure */
typedef struct
{
   binary98 FLAGS;
   binary98 FAMILY;
   binary98 SOCKTYPE;
   binary98 PROTOCOL;
   binary98 NAMELEN;
   pointer CANONNAME;
   pointer NAME;
   pointer NEXT;
} AddressInfoOutputType;

static void string2hex(char *Output, unsigned char *Input, int32_t Length)
{
   char *Out;
   char First;
   char Second;
   
   Out = Output;
   while (Length > 0)
   {
      First = *Input / 0x10;
      Second = *Input % 0x10;
      *Out = char2Hex(First);
      Out++;
      *Out = char2Hex(Second);
      Out++;
      Length--;
      Input++;
   }
   *Out = '\0';
   return;
}


#ifdef GIVESOCKET_METHOD_FORK
/* This set of functions implements the method of passing a socket
** between two unrelated processes documented here: http://../
**
** In a nutshell here is now it works:
** The GIVE-process forks a child-GIVE-process which is responsible
** for handing off the socket to the TAKE-process.  A child process is
** used because GIVE needs to return immediately.
*/

static const char *FormatClientIDAsString(ClientType *CLIENT, char *String)
{  
   char ClientName[20];
   char ClientTask[20];
   PicX2char(ClientName, CLIENT->NAME, 8);
   PicX2char(ClientTask, CLIENT->TASK, 8);
   sprintf(String, "%s_%s", ClientName, ClientTask);
   return(String);
}

static void FormatFileForClientID(ClientType *CLIENT, char *Path)
{  
   char ClientName[20];
   char ClientTask[20];
   string2hex(ClientName, (unsigned char *)CLIENT->NAME, 8);
   string2hex(ClientTask, (unsigned char *)CLIENT->TASK, 8);
   sprintf(Path, "/tmp/%s.%s", ClientName, ClientTask);
}

#ifdef HAVE_MSGHDR_MSG_CONTROL
typedef union 
{
   struct cmsghdr cm;
   char    control[CMSG_SPACE(sizeof(int))];
} control_un_type;
#endif

int extractFdFromMsg(struct msghdr *msg, int32_t *newfdp, int *ErrNoRtn)
{
   int recvfd;
   struct cmsghdr *cmptr;
   #ifdef HAVE_MSGHDR_MSG_CONTROL
   if ( (cmptr = CMSG_FIRSTHDR(msg)) != NULL
      && cmptr->cmsg_len == CMSG_LEN(sizeof(int32_t))
      ) 
   {
      if (cmptr->cmsg_level != SOL_SOCKET)
      {
         *ErrNoRtn = EINVAL;
         #ifdef LOG
         printf("%d: cmsg_level %d != SOL_SOCKET\n",
            getpid(), cmptr->cmsg_level);
         #endif
         return -1;
      }
      if (cmptr->cmsg_type != SCM_RIGHTS)
      {
         *ErrNoRtn = EINVAL;
         #ifdef LOG
         printf("%d: cmsg_type %d != SCM_RIGHTS\n",
            getpid(), cmptr->cmsg_type);
         #endif
         return -1;
      }
      recvfd = *((int32_t *) CMSG_DATA(cmptr));
   } 
   else
   {
      *ErrNoRtn = EINVAL;
      #ifdef LOG
      printf("%d: descriptor was not passed 1\n", getpid());
      #endif
      recvfd = -1;  /* descriptor was not passed */
   }
   #else
   /* *INDENT-OFF* */
   if (msg->msg_accrightslen == sizeof(int32_t))
   {
      recvfd = *newfdp;
   }
   else
   {
      *ErrNoRtn = EINVAL;
      #ifdef LOG
      printf("%d: descriptor was not passed 2\n", getpid());
      #endif
      recvfd = -1;  /* descriptor was not passed */
   }
   /* *INDENT-ON* */
   #endif
   return(recvfd);
}
    
static ssize_t write_fd(int32_t fd, int32_t sendfd)
{
   struct msghdr msg;
   int BytesWritten;
   struct iovec iov[1];
   char *Str = "";

   #ifdef HAVE_MSGHDR_MSG_CONTROL
   static control_un_type control_un;
   struct cmsghdr *cmptr;

   msg.msg_control = control_un.control;
   msg.msg_controllen = sizeof(control_un.control);

   cmptr = CMSG_FIRSTHDR(&msg);
   cmptr->cmsg_len = CMSG_LEN(sizeof(int));
   cmptr->cmsg_level = SOL_SOCKET;
   cmptr->cmsg_type = SCM_RIGHTS;
   *((int *) CMSG_DATA(cmptr)) = sendfd;
   #else
   msg.msg_accrights = (caddr_t)&sendfd;
   msg.msg_accrightslen = sizeof(int32_t);
   #endif

   msg.msg_name = NULL;
   msg.msg_namelen = 0;

   iov[0].iov_base = Str;
   iov[0].iov_len = 1;
   msg.msg_iov = iov;
   msg.msg_iovlen = 1;
 
   if ((BytesWritten = sendmsg(fd, &msg, 0)) < 0)
   {
      int SaveErrNo = errno;
       
      printf("%d: fail to write %d %d\n", getpid(), fd, SaveErrNo);
   }
   
   return BytesWritten;
}

static ssize_t read_fd(int32_t fd, int32_t *recvfd, int *ErrNoRtn)
{
   struct msghdr msg;
   ssize_t       n;
   int32_t       newfd;
   struct iovec  iov[1];
   char          c;

   #ifdef HAVE_MSGHDR_MSG_CONTROL
   static control_un_type control_un;

   msg.msg_control = control_un.control;
   msg.msg_controllen = sizeof(control_un.control);
   #else
   /* question for sam: why does newfd get set here: */
   msg.msg_accrights = (caddr_t) &newfd;
   msg.msg_accrightslen = sizeof(int32_t);
   #endif

   msg.msg_name    = NULL;
   msg.msg_namelen = 0;

   iov[0].iov_base = &c;
   iov[0].iov_len  = 1;
   msg.msg_iov     = iov;
   msg.msg_iovlen  = 1;

   if ( (n = recvmsg(fd, &msg, 0)) < 0)
   {
      *ErrNoRtn = errno;
      *recvfd = -1;
      #ifdef LOG
      printf("%d: recvmsg failed errno = %d\n", getpid(), *ErrNoRtn);
      #endif
   }
   else if (n == 0)
   {
      *recvfd = -1;
      #ifdef LOG
      printf("%d: recvmsg failed due to orderly shutdown\n", getpid());
      #endif
   }
   else
   {
      *recvfd = extractFdFromMsg(&msg, &newfd, ErrNoRtn);
   }
   /* error conditions drop thru here */
   return(n);
}

static void GiveSoc(int32_t Soc,
                    ClientType *CLIENT,
                    binary98 *ERRNO,
                    binary98s *RETCODE)
{
   char Path[200];
   char Buffer[40];
   int Pipes[2];
   int ForkRtn;
  
   FormatFileForClientID(CLIENT, Path);
   unlink(Path);

   #ifdef LOG
   printf("%d: GIVESOCKET(%d, [%s])\n", getpid(),
              Soc,
              FormatClientIDAsString(CLIENT, Buffer)
         );
   #endif

   if (socketpair(AF_LOCAL, SOCK_STREAM, 0, Pipes) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
      #ifdef LOG
      printf("%d: socketpair failed errno = %d\n", getpid(), SaveErrNo);
      #endif
   }
   
   /* in the child process, we do these things:
      1). create one socket server and wait the other process,
          when the other process is connected, send the socket
          descriptor to it.
      2) use the Pipes to cause the exception of the socket 
         descriptor in parent process.
   */
   if ((ForkRtn = fork()) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
      #ifdef LOG
      printf("%d: fork failed errno = %d\n", getpid(), SaveErrNo);
      #endif
   }
   else if (ForkRtn == 0)
   {
      /* This is the child-GIVE-process that waits for TAKE-process
      ** to capture the socket before it exits.
      ** This process does not use ERRNO or RETURN, it just exits
      ** regardless of success or failure.
      */
      int32_t SocketServer;
      struct sockaddr_un ServerAddr;

      #ifdef LOG
      printf("%d: after fork - child\n", getpid());
      fflush(stdout);
      #endif
      close(Pipes[0]);

      memset(&ServerAddr, 0, sizeof(ServerAddr));
      ServerAddr.sun_family = AF_LOCAL;
      strcpy(ServerAddr.sun_path, Path);

      if ((SocketServer= socket(AF_LOCAL, SOCK_STREAM, 0)) < 0 )
      {
         int SaveErrNo = errno;
         #ifdef LOG
         printf("%d: GIVESOCKET - fail to create socket errno = %d |%s|\n",
            getpid(), SaveErrNo, Path);
         fflush(stdout);
         #endif
         exit(0);
      }

      if (bind(SocketServer, (struct sockaddr *)&ServerAddr, sizeof(ServerAddr)) < 0)
      {
         int SaveErrNo = errno;
         #ifdef LOG
         printf("%d: GIVESOCKET - fail to bind socket errno = %d\n",
            getpid(), SaveErrNo);
         fflush(stdout);
         #endif
         exit(0);
      }
      #ifdef LOG
      printf("%d: bind successful for [%s])\n", getpid(), Path);
      fflush(stdout);
      #endif

      if (listen(SocketServer, 5) < 0)
      {
         int SaveErrNo = errno;
         #ifdef LOG
         printf("%d: GIVESOCKET - fail to listen for socket errno=%d\n",
            getpid(), SaveErrNo);
         fflush(stdout);
         #endif
         exit(0);
      }
      
      /* todo: here we should wait for the close of pipe */
      /* Wait for the TAKE-process to connect and take the socket */
      fd_set readfds;
      struct timeval tv;
      int32_t MaxSoc  = SocketServer+1;
      tv.tv_sec  = 4 * 24 * 60 * 60;
      tv.tv_usec = 0;
      FD_ZERO(&readfds);
      FD_SET(SocketServer, &readfds);
      
      #ifdef LOG
      printf("%d: GIVESOCKET - start to take request\n", getpid());
      fflush(stdout);
      #endif
      if (select(MaxSoc, &readfds, NULL, NULL, &tv) != -1)
      {
         /* BUG: We need a loop here to run select again in the event
         ** of a EINT.
         */
         #ifdef LOG
         printf("%d: GIVESOCKET - receive one accept request\n", getpid());
         #endif
         struct sockaddr_un ClientAddr;
         socklen_t ClientLen;
         ClientLen = sizeof(ClientAddr);
         int32_t ClientSock;
         if ((ClientSock = accept(SocketServer, (struct sockaddr *)&ClientAddr, &ClientLen)) >= 0)
         {
            /* send the socket to the TAKE-process */
            write_fd(ClientSock, Soc);
         }
         
         sleep(1);  /* BUG: this may be a race condition */
         close(ClientSock);
      }
      close(SocketServer);
      
      #ifdef LOG
      printf("%d: GIVESOCKET - socket has been taken\n", getpid());
      fflush(stdout);
      #endif
      
      close(Pipes[1]);
      close(Soc);
      unlink(Path);
      exit(0);
   }
   else
   {
      /* This is the parent-GIVE process. 
      ** This basically just returns.
      */
      #ifdef LOG
      printf("%d: after fork - parent\n", getpid());
      #endif
      close(Pipes[1]);
      /* this links the pipe to Soc so we can induce a exception on Soc */
      if (dup2(Pipes[0], Soc) < 0)
      {
         int SaveErrNo = errno;
         #ifdef LOG
         printf("%d: GIVESOCKET - fail to dup2 socket errno = %d\n",
            getpid(), SaveErrNo);
         #endif
         int2bin98(ERRNO, SaveErrNo);
         int2bin98s(RETCODE, -1);
         return;
      }
      
      int2bin98s(RETCODE, 0);
   }
}

static void TakeSoc(int32_t Soc,
                    ClientType *CLIENT,
                    binary98 *ERRNO,
                    binary98s *RETCODE)
{
   char Path[200];
   char Buffer[40];
   int ErrNoRtn;
   int SocketClient;
   struct sockaddr_un ServerAddr;

   #ifdef LOG
   printf("%d: TAKESOCKET(%d, [%s])\n", getpid(),
              Soc,
              FormatClientIDAsString(CLIENT, Buffer)
         );
   #endif

   FormatFileForClientID(CLIENT, Path);
   memset(&ServerAddr, 0, sizeof(ServerAddr));
   ServerAddr.sun_family = AF_LOCAL;
   strcpy(ServerAddr.sun_path, Path);

   if ((SocketClient = socket(AF_LOCAL, SOCK_STREAM, 0)) < 0 )
   {
      int SaveErrNo = errno;
      #ifdef LOG
      printf("%d: TAKESOCKET - fail to create socket errno = %d |%s|\n",
            getpid(), SaveErrNo, Path);
      #endif
   }

   if (connect(SocketClient,
               (struct sockaddr *)&ServerAddr,
               sizeof(ServerAddr)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
      #ifdef LOG
      printf("%d: connect(%d, %s) failed errno = %d\n",
         getpid(), SocketClient, Path, SaveErrNo);
      #endif
      return;
   }
   /* read the socket descriptor */
   int NewSock;
   if (read_fd(SocketClient, &NewSock, &ErrNoRtn) <= 0)
   {
      int2bin98(ERRNO, ErrNoRtn);
      int2bin98s(RETCODE, -1);
      return;
   }
   
   int2bin98s(RETCODE, NewSock);
}

#elif defined GIVESOCKET_METHOD_DAEMON

static void GiveSoc(int Soc,
                    ClientType *CLIENT,
                    binary98 *ERRNO,
                    binary98s *RETCODE)
{
}

static void TakeSoc(int32_t Soc,
                    ClientType *CLIENT,
                    binary98 *ERRNO,
                    binary98s *RETCODE)
{

}
#elif defined GIVESOCKET_METHOD_NONE
/* Intentionally empty */
/* I do not know why I need to have these */
static void GiveSoc(int Soc,
                    ClientType *CLIENT,
                    binary98 *ERRNO,
                    binary98s *RETCODE)
{
}

static void TakeSoc(int32_t Soc,
                    ClientType *CLIENT,
                    binary98 *ERRNO,
                    binary98s *RETCODE)
{

}
#else
#error "Implemented method for GIVESOCKET is not specified"
#endif

static void func_UNKNOWN(void)
{
   #ifdef LOG
   printf("%d: UNKNOWN()\n", getpid());
   #endif
}

static void func_ACCEPT(binary94  *SOCKID,
                 NameType  *NAME,
                 binary98  *ERRNO,
                 binary98s *RETCODE)
{
   int NewS;

   struct sockaddr_in Address;
   socklen_t AddressLen = sizeof(struct sockaddr_in);

   int32_t OldS = bin942int(SOCKID);

   if ((NewS = accept(OldS, (struct sockaddr *)&Address, &AddressLen)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }

   #ifdef LOG
   {
      int32_t tmp = AddressLen;
      printf("%d: ACCEPT(%d, [%d, %d, %x], %d) = %d\n", getpid(),
              OldS,
              Address.sin_family,
              Address.sin_port,
              Address.sin_addr.s_addr,
              tmp,
              NewS
         );
   }
   #endif

   if (NewS < 0)
   {
      /* note that ERRNO and RETCODE set above */
      return;
   }

   if (Address.sin_family == AF_INET)
   {
      int2bin94(&(NAME->FAMILY), EZASOKET_AF_INET);
   }
   else if (Address.sin_family == AF_INET6)
   {
      int2bin94(&(NAME->FAMILY), EZASOKET_AF_INET6);
   }
   else
   {
      if (0)
      {
      /* this is broken on HP, HP returns 24576 for sin_family */
      printf("%d: ACCEPT:sin_family=%d not AF_INET=%d or AF_INET6=%d\n", getpid(),
               Address.sin_family, AF_INET, AF_INET6
	    );
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return;
      }
      else
      {
         int2bin94(&(NAME->FAMILY), EZASOKET_AF_INET);
      }
   }
   int2bin94(&(NAME->PORT), ntohs(Address.sin_port));
#ifdef OPEN_EZASOKET_IPV6
   int2bin94(&(NAME->FLOW_INFO), 0);
   #error "ERROR: need to figure out how to set address for v6"
#else
   int2bin98(&(NAME->IP_ADDRESS), ntohl(Address.sin_addr.s_addr));
#endif

   int2bin98s(RETCODE, NewS);
}

static void func_BIND(binary94   *SOCKID,
               NameType   *NAME,
               binary98   *ERRNO,
               binary98s  *RETCODE)
{
   char *cp;
   struct sockaddr_in Address;
   socklen_t AddressLen = sizeof(struct sockaddr_in);

   int32_t s        = bin942int(SOCKID);
   int32_t Family   = bin942int(&(NAME->FAMILY));

   if (Family == EZASOKET_AF_INET)
   {
      Address.sin_family = AF_INET;
   }
   else if (Family == EZASOKET_AF_INET6)
   {
      Address.sin_family = AF_INET6;
   }
   else
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   Address.sin_port = htons(bin942int(&(NAME->PORT)));
#ifdef OPEN_EZASOKET_IPV6
   if (bin982int(&(NAME->FLOW_INFO)) != 0)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return;
   }
   #error "ERROR: need to figure out how to set address for v6"
#else
   Address.sin_addr.s_addr = htonl(bin982int(&(NAME->IP_ADDRESS)));
   cp = inet_ntoa(Address.sin_addr);
#endif

   #ifdef LOG
   {
      int32_t tmp = AddressLen;
      int32_t name_ip_addr = IP_ADDRESS2int(&(NAME->IP_ADDRESS));
      printf("%d: BIND(%d, [%d, %d, %x | %x(%p)], %d)\n", getpid(),
              s,
              Address.sin_family,
              Address.sin_port,
              Address.sin_addr.s_addr,
              name_ip_addr,
              cp,
              tmp);
   }
   #endif
   if (bind(s, (const struct sockaddr *)&Address, AddressLen))
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void func_CLOSE(binary94  *SOCKID,
                binary98  *ERRNO,
                binary98s *RETCODE)
{
   int32_t s = bin942int(SOCKID);
   #ifdef LOG
   printf("%d: CLOSE(%d)\n", getpid(), s);
   #endif
   if (close(s))
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void func_CONNECT(binary94   *SOCKID,
                  NameType   *NAME,
                  binary98   *ERRNO,
                  binary98s  *RETCODE)
{
   struct sockaddr_in Address;
   socklen_t AddressLen = sizeof(struct sockaddr_in);

   int32_t s        = bin942int(SOCKID);
   int32_t Family   = bin942int(&(NAME->FAMILY));

   if (Family == EZASOKET_AF_INET)
   {
      Address.sin_family = AF_INET;
   }
   else if (Family == EZASOKET_AF_INET6)
   {
      Address.sin_family = AF_INET6;
   }
   else
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   Address.sin_port = htons(bin942int(&(NAME->PORT)));
#ifdef OPEN_EZASOKET_IPV6
   if (bin982int(&(NAME->FLOW_INFO)) != 0)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
   }
   #error "ERROR: need to figure out how to set address for v6"
#else
   Address.sin_addr.s_addr = htonl(bin982int(&(NAME->IP_ADDRESS)));
#endif

   #ifdef LOG
   {
      int32_t tmp = AddressLen;
      int32_t name_ip_addr = IP_ADDRESS2int(&(NAME->IP_ADDRESS));
      printf("%d: CONNECT(%d, [%d, %d, %x | %x], %d)\n", getpid(),
              s,
              Address.sin_family,
              Address.sin_port,
              Address.sin_addr.s_addr,
              name_ip_addr,
              tmp);
   }
   #endif
   if (connect(s, (const struct sockaddr *)&Address, AddressLen))
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

void notImplemented3(const char *funcname)
{
   #ifdef LOG
   printf("%d: %s(not implemented) = -1\n", getpid(), funcname);
   #endif
}

void notImplemented2(binary98s *RETCODE, const char *funcname)
{
   #ifdef LOG
   printf("%d: %s(not implemented) = -1\n", getpid(), funcname);
   #endif
   int2bin98s(RETCODE, -1);
}

void notImplemented(binary98 *ERRNO, binary98s *RETCODE, const char *funcname)
{
   #ifdef LOG
   printf("%d: %s(not implemented) = -1\n", getpid(), funcname);
   #endif
   int2bin98(ERRNO, EINVAL);
   int2bin98s(RETCODE, -1);
}

static void func_FCNTL(binary94  *SOCKID,
                binary98  *COMMAND,
                binary98  *REQARG,
                binary98  *ERRNO,
                binary98s *RETCODE)
{
   int32_t s;
   int32_t Command;
   int32_t ReqArg;
   int Flags;
   
   s = bin942int(SOCKID);
   Command = bin982int(COMMAND);
   ReqArg = bin982int(REQARG);
   
   if ((Command != 3) && (Command != 4))
   {
      #ifdef LOG
      printf("%d: FCNTL - unknown command %d\n", getpid(), Command);
      #endif
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   if (Command == 3)
   {
      Flags = fcntl(s, F_GETFL, 0);
      if (Flags == -1)
      {
         #ifdef LOG
         printf("%d: FCNTL - Fail to get flag for socket\n", getpid());
         #endif
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      char *Tmp = (char *)RETCODE;
      Tmp[0] = 0x00;
      Tmp[1] = 0x00;
      Tmp[2] = 0x00;
      if (Flags & O_NONBLOCK)
      {
         Tmp[3] = 0x04;
      }
      else
      {
         Tmp[3] = 0x00;
      }
   }
   else if (Command == 4)
   {
      if ((ReqArg != 0) && (ReqArg != 4))
      {
         #ifdef LOG
         printf("%d: FCNTL - unknown parameter for set %d\n", getpid(), ReqArg);
         #endif
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      Flags = fcntl(s, F_GETFL, 0);
      if (Flags == -1)
      {
         #ifdef LOG
         printf("%d: FCNTL - Fail to get flag for socket\n", getpid());
         #endif
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      if (ReqArg == 4)
      {
         Flags = Flags | O_NONBLOCK;
      }
      else if (ReqArg == 0)
      {
         Flags = Flags & ~O_NONBLOCK;
      }
      if (fcntl(s, F_SETFL, Flags) < 0)
      {
         int SaveErrNo = errno;
         int2bin98(ERRNO, SaveErrNo);
         int2bin98s(RETCODE, -1);
      }
      else
      {
         int2bin98s(RETCODE, 0);
      }
   }
}

static void func_FREEADDRINFO(binary98  *ADDRINFO,
                       binary98  *ERRNO,
                       binary98s *RETCODE)
{
   #ifdef LOG
   printf("%d: FREEADDRINFO %p\n", getpid(), ADDRINFO);
   #endif
   /* freeaddrinfo((struct addrinfo *)(ADDRINFO)); gives warning on HPUX for potential misaligned pointer */
   freeaddrinfo((void *)(ADDRINFO));
   /* Bug:  FREEADDRINFO always return success? */
   int2bin98s(RETCODE, 0);
}

static void func_GETADDRINFO(picX      *NODE,
                      binary98  *NODELEN,
                      picX      *SERVICE,
                      binary98  *SERVLEN,
                      pointer   *HINTS,
                      pointer   *RES,
                      binary98  *CANNLEN,
                      binary98  *ERRNO,
                      binary98s *RETCODE)
{
   char NodeBuffer[255+1];
   char ServiceBuffer[32+1];
   
   char *Node;
   int32_t NodeLen;
   char *Service;
   int32_t ServiceLen;
   AddressInfoType *Hint;
   struct addrinfo AddressInfoBase;
   struct addrinfo *AddressInfo;
   struct addrinfo *Result;
   
   if ((NODE != NULL) && (NODELEN == NULL))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   if ((SERVICE!= NULL) && (SERVLEN == NULL))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   #ifdef LOG
   printf("%d: GETADDRINFO %p, %p, %p, %p\n", getpid(), NODE, SERVICE, HINTS, RES);
   #endif
   
   if (NODE != NULL)
   {
      NodeLen = bin982int(NODELEN);
      if (NodeLen > 255)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
      }
      Node = NodeBuffer;
      memcpy(Node, NODE, NodeLen);
      Node[NodeLen] = '\0';
   }
   else
   {
      Node = NULL;
   }
   
   if (SERVICE != NULL)
   {
      ServiceLen = bin982int(SERVLEN);
      if (ServiceLen > 32)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
      }
      Service = ServiceBuffer;
      /* convert the service to lower */
      Service[ServiceLen] = '\0';
      while (ServiceLen > 0)
      {
         ServiceLen--;
         if ((SERVICE[ServiceLen] >= 'A') && (SERVICE[ServiceLen] <= 'Z'))
         {
            Service[ServiceLen] = SERVICE[ServiceLen]-'A'+'a';
         }
         else
         {
            Service[ServiceLen] = SERVICE[ServiceLen];
         }
      }      
   }
   else
   {
      Service = NULL;
   }
   
   if (HINTS != NULL)
   {
      Hint = (AddressInfoType *)HINTS;
      int32_t Family = bin982int(&(Hint->FAMILY));
      if (Family == EZASOKET_AF_INET)
      {
         AddressInfoBase.ai_family = AF_INET;
      }
      else if (Family == EZASOKET_AF_INET6)
      {
         AddressInfoBase.ai_family = AF_INET6;
      }
      else if (Family == EZASOKET_AF_UNSPEC)
      {
         AddressInfoBase.ai_family = AF_UNSPEC;
      }
      else
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
 
      AddressInfoBase.ai_flags = bin982int(&(Hint->FLAGS));
      AddressInfoBase.ai_socktype = bin982int(&(Hint->SOCKTYPE));
      AddressInfoBase.ai_protocol = bin982int(&(Hint->PROTOCOL));
      AddressInfoBase.ai_addrlen = 0;
      AddressInfoBase.ai_addr = NULL;
      AddressInfoBase.ai_canonname = NULL;
      AddressInfoBase.ai_next = NULL;
   }
   else
   {
      AddressInfoBase.ai_family = AF_UNSPEC;
      AddressInfoBase.ai_flags = 0;
      AddressInfoBase.ai_socktype = 0;
      AddressInfoBase.ai_protocol = 0;
      AddressInfoBase.ai_addrlen = 0;
      AddressInfoBase.ai_addr = NULL;
      AddressInfoBase.ai_canonname = NULL;
      AddressInfoBase.ai_next = NULL;
   }
   AddressInfo = &AddressInfoBase;
   
   #ifdef LOG
   printf("%d: GETADDRINFO %s, %s, %p, %p\n", getpid(), Node, Service, AddressInfo, RES);
   #endif
   
   int SaveErrNo;
   if ((SaveErrNo = getaddrinfo(Node, Service, AddressInfo, &Result)) != 0)
   {
      #ifdef LOG
      printf("%d: Fail to get adress info: %s\n", getpid(), gai_strerror(SaveErrNo));
      #endif
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      /* Bug: here we should allocate the memory for the return value
      ** and use freeaddrinfo to free the memory allocated by getaddrinfo.
      ** now we don't allocate the memory.
      */
      
      *RES = (pointer)Result;
      int2bin98((binary98 *)&(Result->ai_flags),    Result->ai_flags);
      int2bin98((binary98 *)&(Result->ai_family),   Result->ai_family);
      int2bin98((binary98 *)&(Result->ai_socktype), Result->ai_socktype);
      int2bin98((binary98 *)&(Result->ai_protocol), Result->ai_protocol);
      int2bin98((binary98 *)&(Result->ai_addrlen),  Result->ai_addrlen);
      if (CANNLEN != NULL)
      {
         if (Result->ai_canonname != NULL)
         {
            int2bin98(CANNLEN, strlen(Result->ai_canonname));
         }
         else
         {
            int2bin98(CANNLEN, 0);
         }
      }
      /* Bug: we have to swap the position for CONN_NAME and NAME*/
      Result = Result->ai_next;
      do
      {
         if (Result == NULL)
         {
            break;
         }
         
         int2bin98((binary98 *)&(Result->ai_flags),    Result->ai_flags);
         int2bin98((binary98 *)&(Result->ai_family),   Result->ai_family);
         int2bin98((binary98 *)&(Result->ai_socktype), Result->ai_socktype);
         int2bin98((binary98 *)&(Result->ai_protocol), Result->ai_protocol);
         int2bin98((binary98 *)&(Result->ai_addrlen),  Result->ai_addrlen);
         Result = Result->ai_next;
      }while(1);
      int2bin98s(RETCODE, 0);
   }
}

static void func_GETCLIENTID(ClientType *CLIENT,
                             binary98          *ERRNO,
                             binary98s         *RETCODE)
{
   /* only the pid is considered now */
   int32_t pid = getpid();
   string2hex(CLIENT->TASK, (unsigned char *)&pid, sizeof(int32_t));
}

static void func_GETHOSTBYADDR(binary98  *HOSTADDR,
                        pointer   *HOSTENT,
                        binary98s *RETCODE)
{
   const char *Address;
   struct in_addr InAddr;
   InAddr.s_addr   = htonl(bin982int(HOSTADDR));
   struct hostent *RetAddr;
   
   #ifdef LOG
   printf("%d: GETHOSTBYADDR %d(%s)\n", getpid(), InAddr.s_addr, inet_ntoa(InAddr));
   #endif
   if ((RetAddr = gethostbyaddr(&InAddr.s_addr, sizeof(InAddr), AF_INET)) == NULL)
   {
      int2bin98s(RETCODE, -1);
   }
   else
   {
      #ifdef LOG
      {
	 /* changed to %p for RetAddr->h_addr_list[0] to allow this to work on a 64 bit compile.
	 ** if %p is not available, then need to use ifdefs with int32t/int64_ and %d/%ld.
	 */
         printf("%d: GETHOSTBYADDR: %s, %d, %d, %p\n", getpid(), RetAddr->h_name, RetAddr->h_addrtype, 
                                             RetAddr->h_length, RetAddr->h_addr_list[0]);
      }
      #endif
      *HOSTENT = (pointer)RetAddr;
      int2bin98s(RETCODE, 0);
   }
}

static void func_GETHOSTBYNAME(binary98  *NAMELEN,
                        picX      *NAME,
                        pointer  *HOSTENT,
                        binary98s *RETCODE)
{
   char HostName[255+1];
   int32_t NameLength;
   struct hostent *RetAddr;
   
   if ((NAMELEN == NULL) || (NAME == NULL))
   {
      int2bin98s(RETCODE, -1);
      return;
   }
   NameLength = bin982int(NAMELEN);
   if (NameLength > 255)
   {
      int2bin98s(RETCODE, -1);
      return;
   }
   memcpy(HostName, NAME, NameLength);
   HostName[NameLength] = '\0';
   
   #ifdef LOG
   printf("%d: GETHOSTBYNAME %s\n", getpid(), HostName);
   #endif
   if ((RetAddr = gethostbyname((const char *)HostName)) == NULL)
   {
      int2bin98s(RETCODE, -1);
   }
   else
   {
      #ifdef LOG
      printf("%d: GETHOSTBYNAME: %s, %d\n", getpid(), RetAddr->h_name, RetAddr->h_addrtype);
      #endif
      *HOSTENT = (pointer)RetAddr;
      int2bin98s(RETCODE, 0);
   }
}

static void func_GETHOSTID(binary98s *RETCODE)
{
   int32_t HostID;
   HostID = gethostid();
   #ifdef LOG
   printf("%d: GETHOSTID(%d)\n", getpid(), HostID);
   #endif
   int2bin98s(RETCODE, HostID);
}

static void func_GETHOSTNAME(binary98  *NAMELEN,   /* in */
                      picX      *NAME,      /* out */
                      binary98  *ERRNO,
                      binary98s *RETCODE)
{
   int32_t namelen;
   char name[256];

   namelen = bin982int(NAMELEN);

   #ifdef LOG
   printf("%d: GETHOSTNAME(%d)\n", getpid(), namelen);
   #endif

   if (namelen > 255)
   {
      int2bin98(ERRNO, ENAMETOOLONG);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (gethostname(name, namelen))
      {
         int SaveErrNo = errno;
         int2bin98(ERRNO, SaveErrNo);
         int2bin98s(RETCODE, -1);
      }
      else
      {
         int newnamelen = strlen(name);   /* bug: get rid of strlen */
         if (newnamelen > namelen)
         {
            int2bin98(ERRNO, ENAMETOOLONG);
            int2bin98s(RETCODE, -1);
         }
         else
         {
            str2picX(NAME, namelen, name, newnamelen);
            int2bin98(ERRNO, 0);
            int2bin98s(RETCODE, 0);
         }
      }
   }
}

static void func_GETNAMEINFO(NameType        *NAME,
                      binary98        *NAMELEN,
                      picX            *HOST,
                      binary98        *HOSTLEN,
                      picX            *SERVICE,
                      binary98        *SERVLEN,
                      binary98        *FLAGS,
                      binary98        *ERRNO,
                      binary98s       *RETCODE)
{
   char Service[32+1];
   char Host[255+1];
   
   char *HostInfo;
   char *ServiceInfo;
   int32_t HostLen;
   int32_t ServiceLen;
   
   int32_t Flags;
   int RetVal;
   
   struct sockaddr_in Address;
   socklen_t AddressLen = sizeof(struct sockaddr_in);

   /* Bug: NAMELEN field is ignored here */
   int32_t Family   = bin942int(&(NAME->FAMILY));

   if (Family == EZASOKET_AF_INET)
   {
      Address.sin_family = AF_INET;
   }
   else if (Family == EZASOKET_AF_INET6)
   {
      Address.sin_family = AF_INET6;
   }
   else
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   Address.sin_port = htons(bin942int(&(NAME->PORT)));
#ifdef OPEN_EZASOKET_IPV6
   if (bin982int(&(NAME->FLOW_INFO)) != 0)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return;
   }
   #error "ERROR: need to figure out how to set address for v6"
#else
   Address.sin_addr.s_addr = htonl(bin982int(&(NAME->IP_ADDRESS)));
#endif

   if (HOST != NULL)
   {
      if (HOSTLEN != NULL)
      {
         HostLen = bin982int(HOSTLEN);
         if (HostLen > 255)
         {
            int2bin98(ERRNO, EINVAL);
            int2bin98s(RETCODE, -1);
            return ;
         }
         HostInfo = Host;
      }
      else
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
   }
   else
   {
      HostInfo = NULL;
      HostLen = 0;
   }
   
   if (SERVICE != NULL)
   {
      if (SERVLEN != NULL)
      {
         ServiceLen = bin982int(SERVLEN);
         if (ServiceLen > 32)
         {
            int2bin98(ERRNO, EINVAL);
            int2bin98s(RETCODE, -1);
            return ;
         }
         ServiceInfo = Service;
      }
      else
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
   }
   else
   {
      ServiceInfo = NULL;
      ServiceLen = 0;
   }
   
   if ((HostInfo == NULL) && (HostInfo == NULL))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   if (FLAGS != NULL)
   {
      Flags = bin982int(FLAGS);
   }
   else
   {
      Flags = 0;
   }
   
   #ifdef LOG
   {
      int32_t tmp = AddressLen;
      printf("%d: %p %d %p %d %p %d %d\n", getpid(), &Address, tmp, HostInfo, HostLen, ServiceInfo, ServiceLen, Flags);
   }
   #endif
   
   RetVal = getnameinfo((struct sockaddr *)&Address, AddressLen, HostInfo, HostLen, ServiceInfo, ServiceLen, Flags);
   if (RetVal != 0)
   {
      #ifdef LOG
      printf("%d: %s\n", getpid(), gai_strerror(RetVal));
      #endif
      int SaveErrNo = RetVal;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (HostInfo != NULL)
      {
         int NewHostLen = strlen(HostInfo);
         if (NewHostLen > HostLen)
         {
            NewHostLen = HostLen;
         }
         str2picX(HOST, HostLen, HostInfo, NewHostLen);
         int2bin98(HOSTLEN, NewHostLen);
      }
      if (ServiceInfo != NULL)
      {
         int NewServiceLen = strlen(ServiceInfo);
         if (NewServiceLen > ServiceLen)
         {
            NewServiceLen = ServiceLen;
         }
         str2picX(HOST, ServiceLen, ServiceInfo, NewServiceLen);
         int2bin98(SERVLEN, NewServiceLen);
      }
      int2bin98s(RETCODE, 0);
   }
}

static void func_GETPEERNAME(binary94        *SOCKID,
                      NameType        *NAME,
                      binary98        *ERRNO,
                      binary98s       *RETCODE)
{
   int32_t s;
   
   struct sockaddr_in Address;
   socklen_t AddressLen = sizeof(struct sockaddr_in);
   
   s = bin942int(SOCKID);
   if (NAME == NULL)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   if (getpeername(s, (struct sockaddr *)&Address, &AddressLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin94(&(NAME->FAMILY), Address.sin_family);
      int2bin94(&(NAME->PORT), ntohs((Address.sin_port)));
      #ifdef OPEN_EZASOKET_IPV6
      #error "ERROR: need to figure out how to set address for v6"
      #else
      int2bin98(&(NAME->IP_ADDRESS), ntohl(Address.sin_addr.s_addr));
      #endif
      int2bin98s(RETCODE, 0);
   }
}

static void func_GETSOCKNAME(binary94        *SOCKID,
                      NameType        *NAME,
                      binary98        *ERRNO,
                      binary98s       *RETCODE)
{
   int32_t s;
   
   struct sockaddr_in Address;
   socklen_t AddressLen = sizeof(struct sockaddr_in);
   
   s = bin942int(SOCKID);
   if (NAME == NULL)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   if (getsockname(s, (struct sockaddr *)&Address, &AddressLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin94(&(NAME->FAMILY), Address.sin_family);
      int2bin94(&(NAME->PORT), ntohs((Address.sin_port)));
      #ifdef OPEN_EZASOKET_IPV6
      #error "ERROR: need to figure out how to set address for v6"
      #else
      int2bin98(&(NAME->IP_ADDRESS), ntohl(Address.sin_addr.s_addr));
      #endif
      int2bin98s(RETCODE, 0);
   }
}

typedef void (*ProcessOptionForOutputFunc)(int32_t s, 
                                           int Level, 
                                           int Option, 
                                           void *Val, 
                                           binary98 *OPTLEN,
                                           binary98 *ERRNO,
                                           binary98s *RETCODE);

typedef void (*ProcessOptionForInputFunc)(int32_t s,
                                          int Level, 
                                          int Option,  
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE);

struct OptionMatchPair
{
   int Level;
   int InternalOption;
   uint32_t ExternalOption;
   ProcessOptionForInputFunc ProcessOptionForInputFunc;
   ProcessOptionForOutputFunc ProcessOptionForOutputFunc;
};

#ifndef TCP_KEEPALIVE
   #define TCP_KEEPALIVE 0x8
#endif

static void ProcessOptionForInput(int32_t s, 
                                  int Level, 
                                  int Option, 
                                  void *Val, 
                                  int Length,
                                  binary98 *ERRNO,
                                  binary98s *RETCODE)
{
   char ErrorInfo[100];
   sprintf(ErrorInfo, "SETSOCKOPT - option: %d", Option);
   notImplemented(ERRNO, RETCODE, ErrorInfo);
}

static void ProcessOptionForOutput(int32_t s,
                                   int Level, 
                                   int Option,  
                                   void *Val, 
                                   binary98 *OPTLEN,
                                   binary98 *ERRNO,
                                   binary98s *RETCODE)
{
   char ErrorInfo[100];
   sprintf(ErrorInfo, "GETSOCKOPT - option: %d", Option);
   notImplemented(ERRNO, RETCODE, ErrorInfo);
}

static void ProcessSoTypeForOutput(int32_t s, 
                                   int Level, 
                                   int Option, 
                                   void *Val, 
                                   binary98 *OPTLEN,
                                   binary98 *ERRNO,
                                   binary98s *RETCODE)
{
   int SoType;
   socklen_t OptLen;
   OptLen = sizeof(SoType);
   if (getsockopt(s, Level, Option, &SoType, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      int2bin98(Val, SoType);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoSndBufForInput(int32_t s, 
                                    int Level, 
                                    int Option, 
                                    void *Val, 
                                    int Length,
                                    binary98 *ERRNO,
                                    binary98s *RETCODE)
{
   int SndBufSize;
   SndBufSize = bin982int(Val);
   if (setsockopt(s, Level, Option, &SndBufSize, sizeof(SndBufSize)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoSndBufForOutput(int32_t s, 
                                   int Level, 
                                   int Option, 
                                   void *Val, 
                                   binary98 *OPTLEN,
                                   binary98 *ERRNO,
                                   binary98s *RETCODE)
{
   int SndBufSize;
   socklen_t OptLen;
   OptLen = sizeof(SndBufSize);
   if (getsockopt(s, Level, Option, &SndBufSize, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, SndBufSize);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoReuseAddrForOutput(int32_t s, 
                                   int Level, 
                                   int Option, 
                                   void *Val, 
                                   binary98 *OPTLEN,
                                   binary98 *ERRNO,
                                   binary98s *RETCODE)
{
   int Enable;
   socklen_t OptLen;
   OptLen = sizeof(Enable);
   if (getsockopt(s, Level, Option, &Enable, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, Enable);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoReuseAddrForInput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       int Length,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int Enable;
   Enable = bin982int(Val);
   if (Enable > 0)
   {
      Enable = 1;
   }
   if (setsockopt(s, Level, Option, &Enable, sizeof(Enable)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoRcvBufForInput(int32_t s, 
                                    int Level, 
                                    int Option, 
                                    void *Val, 
                                    int Length,
                                    binary98 *ERRNO,
                                    binary98s *RETCODE)
{
   int RcvBufSize;
   RcvBufSize = bin982int(Val);
   if (setsockopt(s, Level, Option, &RcvBufSize, sizeof(RcvBufSize)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoRcvBufForOutput(int32_t s, 
                                    int Level, 
                                    int Option, 
                                    void *Val, 
                                    binary98 *OPTLEN,
                                    binary98 *ERRNO,
                                    binary98s *RETCODE)
{
   int RcvBufSize;
   socklen_t OptLen;
   OptLen = sizeof(RcvBufSize);
   if (getsockopt(s, Level, Option, &RcvBufSize, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, RcvBufSize);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoOOBINLineForInput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       int Length,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int OOBINLine;
   OOBINLine = bin982int(Val);
   if (setsockopt(s, Level, Option, &OOBINLine, sizeof(OOBINLine)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoOOBINLineForOutput(int32_t s, 
                                    int Level, 
                                    int Option, 
                                    void *Val, 
                                    binary98 *OPTLEN,
                                    binary98 *ERRNO,
                                    binary98s *RETCODE)
{
   int OOBINLine;
   socklen_t OptLen;
   OptLen = sizeof(OOBINLine);
   if (getsockopt(s, Level, Option, &OOBINLine, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, OOBINLine);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoKeepAliveForInput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       int Length,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int KeepAlive;
   KeepAlive = bin982int(Val);
   if (setsockopt(s, Level, Option, &KeepAlive, sizeof(KeepAlive)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoKeepAliveForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int KeepAlive;
   socklen_t OptLen;
   OptLen = sizeof(KeepAlive);
   if (getsockopt(s, Level, Option, &KeepAlive, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, KeepAlive);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

struct LINGER
{
   binary98 ONOFF;
   binary98 LINGER;
};
static void ProcessSoLingerForInput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       int Length,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   struct linger Linger;
   struct LINGER *LINGER = (struct LINGER *)Val;
   Linger.l_onoff = bin982int(&LINGER->ONOFF);
   Linger.l_linger = bin982int(&LINGER->LINGER);
   if (setsockopt(s, Level, Option, &Linger, sizeof(Linger)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoLingerForOutput(int32_t s, 
                                    int Level, 
                                    int Option, 
                                    void *Val, 
                                    binary98 *OPTLEN,
                                    binary98 *ERRNO,
                                    binary98s *RETCODE)
{
   struct linger Linger;
   socklen_t OptLen;
   OptLen = sizeof(Linger);
   if (getsockopt(s, Level, Option, &Linger, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      struct LINGER *LINGER = (struct LINGER *)Val;
      int2bin98(&LINGER->ONOFF, Linger.l_onoff);
      int2bin98(&LINGER->LINGER, Linger.l_linger);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoErrorForOutput(int32_t s, 
                                    int Level, 
                                    int Option, 
                                    void *Val, 
                                    binary98 *OPTLEN,
                                    binary98 *ERRNO,
                                    binary98s *RETCODE)
{
   int Error;
   socklen_t OptLen;
   OptLen = sizeof(Error);
   if (getsockopt(s, Level, Option, &Error, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, Error);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoBroadcastForInput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       int Length,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int Broadcast;
   Broadcast = bin982int(Val);
   if (Broadcast > 0)
   {
      Broadcast = 1;
   }
   if (setsockopt(s, Level, Option, &Broadcast, sizeof(Broadcast)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessSoBroadcastForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int Broadcast;
   socklen_t OptLen;
   OptLen = sizeof(Broadcast);
   if (getsockopt(s, Level, Option, &Broadcast, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, Broadcast);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6V6OnlyForInput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       int Length,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int V6Only;
   V6Only = bin982int(Val);
   if (setsockopt(s, Level, Option, &V6Only, sizeof(V6Only)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6V6OnlyForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int V6Only;
   socklen_t OptLen;
   OptLen = sizeof(V6Only);
   if (getsockopt(s, Level, Option, &V6Only, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, V6Only);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6UnicastHopsForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
   int UnicastHops;
   UnicastHops = bin98s2int(Val);
   if ((UnicastHops < -1) || (UnicastHops > 255))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   if (setsockopt(s, Level, Option, &UnicastHops, sizeof(UnicastHops)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6UnicastHopsForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int UnicastHops;
   socklen_t OptLen;
   OptLen = sizeof(UnicastHops);
   if (getsockopt(s, Level, Option, &UnicastHops, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98s(Val, UnicastHops);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6MulticastLpForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
   int MulticastLp;
   MulticastLp = bin982int(Val);
   if (setsockopt(s, Level, Option, &MulticastLp, sizeof(MulticastLp)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6MulticastLpForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int MulticastLp;
   socklen_t OptLen;
   OptLen = sizeof(MulticastLp);
   if (getsockopt(s, Level, Option, &MulticastLp, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, MulticastLp);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6MulticastIfForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
   unsigned int MulticastIf;
   MulticastIf = bin982int(Val);
   if (setsockopt(s, Level, Option, &MulticastIf, sizeof(MulticastIf)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6MulticastIfForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   unsigned int MulticastIf;
   socklen_t OptLen;
   OptLen = sizeof(MulticastIf);
   if (getsockopt(s, Level, Option, &MulticastIf, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98(Val, MulticastIf);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6MulticastHopsForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
   int MulticastHops;
   MulticastHops = bin98s2int(Val);
   if ((MulticastHops < -1) || (MulticastHops > 255))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   if (setsockopt(s, Level, Option, &MulticastHops, sizeof(MulticastHops)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpV6MulticastHopsForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   int MulticastHops;
   socklen_t OptLen;
   OptLen = sizeof(MulticastHops);
   if (getsockopt(s, Level, Option, &MulticastHops, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98s(Val, MulticastHops);
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}


struct IPV6_MREQ
{
   binary98 MULTIADDR;
   binary98 FILLER;
   binary98 INTERFACE;
};

static void ProcessIpV6LeaveGroupForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
#ifdef OPEN_EZASOKET_IPV6
   struct IPV6_MREQ *IPV6_MREQ;
   
   struct ipv6_mreq IPV6_MReq;
   
   IPV6_MREQ = (struct IPV6_MREQ  *)Val;
   #error "ERROR: need to figure out how to set address for v6"
   IPV6_MReq.ipv6mr_interface = bin982int(&IPV6_MREQ->INTERFACE);
   
   if (setsockopt(s, Level, Option, &IPV6_MReq, sizeof(IPV6_MReq)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
#else
   notImplemented(ERRNO, RETCODE, "IpV6LeaveGroup");
#endif
}

static void ProcessIpV6JoinGroupForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
#ifdef OPEN_EZASOKET_IPV6
   struct IPV6_MREQ *IPV6_MREQ;
   
   struct ipv6_mreq IPV6_MReq;
   
   IPV6_MREQ = (struct IPV6_MREQ  *)Val;
   #error "ERROR: need to figure out how to set address for v6"
   IPV6_MReq.ipv6mr_interface = bin982int(&IPV6_MREQ->INTERFACE);
   
   if (setsockopt(s, Level, Option, &IPV6_MReq, sizeof(IPV6_MReq)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
#else
   notImplemented(ERRNO, RETCODE, "IpV6JoinGroup");
#endif
}

static void ProcessIpMulticastTTLForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
   unsigned char MulticastTTL;
   MulticastTTL = *((unsigned char *)Val);
   if (setsockopt(s, Level, Option, &MulticastTTL, sizeof(MulticastTTL)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpMulticastTTLForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   unsigned char MulticastTTL;
   socklen_t OptLen;
   OptLen = sizeof(MulticastTTL);
   if (getsockopt(s, Level, Option, &MulticastTTL, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      *((unsigned char *)Val) = MulticastTTL;
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpMulticastLoopForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
   char MulticastLoop;
   MulticastLoop = *((char *)Val);
   if ((MulticastLoop != 0x01) && (MulticastLoop != 0x00))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
   }
   
   if (setsockopt(s, Level, Option, &MulticastLoop, sizeof(MulticastLoop)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpMulticastLoopForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   char MulticastLoop;
   socklen_t OptLen;
   OptLen = sizeof(MulticastLoop);
   if (getsockopt(s, Level, Option, &MulticastLoop, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      *((char *)Val) = MulticastLoop;
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpMulticastIfForInput(int32_t s, 
                                          int Level, 
                                          int Option, 
                                          void *Val, 
                                          int Length,
                                          binary98 *ERRNO,
                                          binary98s *RETCODE)
{
   unsigned int Address;
   Address = htonl(bin982int((IpAddressType *)Val));
   
   if (setsockopt(s, Level, Option, &Address, sizeof(Address)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpMulticastIfForOutput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       binary98 *OPTLEN,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   unsigned int Address;
   socklen_t OptLen;
   OptLen = sizeof(Address);
   if (getsockopt(s, Level, Option, &Address, &OptLen) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (bin982int(OPTLEN) < OptLen)
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      
      int2bin98((IpAddressType *)Val, ntohl(Address));
      int2bin98(OPTLEN, OptLen);
      int2bin98s(RETCODE, 0);
   }
}

struct IP_MREQ
{
   binary98 MULTIADDR;
   binary98 INTERFACE;
};
static void ProcessIpDropMemberForInput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       int Length,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   struct IP_MREQ *IP_MREQ;
   struct ip_mreq IP_MReq;

   memset( &IP_MReq, 0, sizeof(IP_MReq));
   IP_MREQ = (struct IP_MREQ  *)Val;
   IP_MReq.imr_multiaddr.s_addr = htonl(bin982int(&IP_MREQ->MULTIADDR));
   IP_MReq.imr_interface.s_addr = htonl(bin982int(&IP_MREQ->INTERFACE));
   
   if (setsockopt(s, Level, Option, &IP_MReq, sizeof(IP_MReq)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void ProcessIpAddMemberForInput(int32_t s, 
                                       int Level, 
                                       int Option, 
                                       void *Val, 
                                       int Length,
                                       binary98 *ERRNO,
                                       binary98s *RETCODE)
{
   struct IP_MREQ *IP_MREQ;
   struct ip_mreq IP_MReq;

   memset( &IP_MReq, 0, sizeof(IP_MReq));
   IP_MREQ = (struct IP_MREQ  *)Val;
   IP_MReq.imr_multiaddr.s_addr = htonl(bin982int(&IP_MREQ->MULTIADDR));
   IP_MReq.imr_interface.s_addr = htonl(bin982int(&IP_MREQ->INTERFACE));
   
   if (setsockopt(s, Level, Option, &IP_MReq, sizeof(IP_MReq)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static struct OptionMatchPair OptionMatchPairs[] = 
{
   {0,            0,                    0,       NULL,                           NULL},
   {IPPROTO_IP,   IP_ADD_MEMBERSHIP,    1048581, ProcessIpAddMemberForInput,     NULL},
   {IPPROTO_IP,   IP_DROP_MEMBERSHIP,   1048582, ProcessIpDropMemberForInput,    NULL},
   {IPPROTO_IP,   IP_MULTICAST_IF,      1048583, ProcessIpMulticastIfForInput,   ProcessIpMulticastIfForOutput},
   {IPPROTO_IP,   IP_MULTICAST_LOOP,    1048580, ProcessIpMulticastLoopForInput, ProcessIpMulticastLoopForOutput},
   {IPPROTO_IP,   IP_MULTICAST_TTL,     1048579, ProcessIpMulticastTTLForInput,  ProcessIpMulticastTTLForOutput},
   {IPPROTO_IPV6, IPV6_JOIN_GROUP,      65541,   ProcessIpV6JoinGroupForInput,   NULL},
   {IPPROTO_IPV6, IPV6_LEAVE_GROUP,     65542,   ProcessIpV6LeaveGroupForInput,  NULL},
   {IPPROTO_IPV6, IPV6_MULTICAST_HOPS,  65545,   ProcessIpV6MulticastHopsForInput,ProcessIpV6MulticastHopsForOutput},
   {IPPROTO_IPV6, IPV6_MULTICAST_IF,    65543,   ProcessIpV6MulticastIfForInput, ProcessIpV6MulticastIfForOutput},
   {IPPROTO_IPV6, IPV6_MULTICAST_LOOP,  65540,   ProcessIpV6MulticastLpForInput, ProcessIpV6MulticastLpForOutput},
   {IPPROTO_IPV6, IPV6_UNICAST_HOPS,    65539,   ProcessIpV6UnicastHopsForInput, ProcessIpV6UnicastHopsForOutput},
   {IPPROTO_IPV6, IPV6_V6ONLY,          65546,   ProcessIpV6V6OnlyForInput,      ProcessIpV6V6OnlyForOutput},
   /* Bug: not supported now 
   ** {SOL_SOCKET,   SO_ASCII,             32,    ProcessOptionForInput, ProcessOptionForOutput},
   ** {SOL_SOCKET,   SO_DEBUG,             32,    ProcessOptionForInput, ProcessOptionForOutput},
   ** {SOL_SOCKET,   SO_EBCDIC,            32,    ProcessOptionForInput, ProcessOptionForOutput},
   */
   {SOL_SOCKET,   SO_BROADCAST,         32,      ProcessSoBroadcastForInput,      ProcessSoBroadcastForOutput},
   {SOL_SOCKET,   SO_ERROR,             4103,    NULL,                            ProcessSoErrorForOutput},
   {SOL_SOCKET,   SO_LINGER,            128,     ProcessSoLingerForInput,         ProcessSoLingerForOutput},
   {SOL_SOCKET,   SO_KEEPALIVE,         8,       ProcessSoKeepAliveForInput,      ProcessSoKeepAliveForOutput},
   {SOL_SOCKET,   SO_OOBINLINE,         256,     ProcessSoOOBINLineForInput,      ProcessSoOOBINLineForOutput},
   {SOL_SOCKET,   SO_RCVBUF,            4098,    ProcessSoRcvBufForInput,         ProcessSoRcvBufForOutput},
   {SOL_SOCKET,   SO_REUSEADDR,         4,       ProcessSoReuseAddrForInput,      ProcessSoReuseAddrForOutput},
   {SOL_SOCKET,   SO_SNDBUF,            4097,    ProcessSoSndBufForInput,         ProcessSoSndBufForOutput},
   {SOL_SOCKET,   SO_TYPE,              4104,    NULL,                            ProcessSoTypeForOutput},
   {IPPROTO_TCP, TCP_KEEPALIVE, 0x80000008, ProcessOptionForInput,                ProcessOptionForOutput},
   {IPPROTO_TCP, TCP_NODELAY,   0x80000001, ProcessOptionForInput,                ProcessOptionForOutput}
};

static struct OptionMatchPair *ProcessOptionName(unsigned int Option)
{
   int i;

   for (i=1;i <sizeof(OptionMatchPairs)/sizeof(struct OptionMatchPair)-1; i++)
   {
      if (OptionMatchPairs[i].ExternalOption == Option)
      {
         return &OptionMatchPairs[i];
      }
   }
   return NULL;
}
 
static void func_GETSOCKOPT(binary94        *SOCKID,
                     binary98        *OPTNAME,
                     pointer          OPTVAL,
                     binary98        *OPTLEN,
                     binary98        *ERRNO,
                     binary98s       *RETCODE)
{
   int32_t s;
   uint32_t OptName;
   struct OptionMatchPair *Option;
   
   /* Bug: Now i assume that the memory is allocated in cobol 
   ** and passed with OPTVAL,
   ** the programmer must know the memory size for the specified opition 
   */
   s = bin942int(SOCKID);
   OptName = bin982int(OPTNAME);
   #ifdef LOG
   printf("%d: GETSOCKOPT %d\n", getpid(), OptName);
   #endif
   
   Option = ProcessOptionName(OptName);
   if ((Option == NULL) || (Option->ProcessOptionForOutputFunc == NULL))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   #ifdef LOG
   printf("%d: GETSOCKOPT %d %d %p\n", getpid(), OptName, Option->InternalOption, OPTVAL);
   #endif
   Option->ProcessOptionForOutputFunc(s,
                                      Option->Level, 
                                      Option->InternalOption,
                                      (void *)OPTVAL, 
                                      OPTLEN,
                                      ERRNO,
                                      RETCODE
                                      );
}

static void func_GIVESOCKET(binary94          *SOCKID,
                            ClientType        *CLIENT,
                            binary98          *ERRNO,
                            binary98s         *RETCODE)
{  
#ifdef GIVESOCKET_METHOD_NONE
   /* create the server for client */
   int32_t s = bin942int(SOCKID);
   GiveSoc(s, CLIENT, ERRNO, RETCODE);
#endif
}

static void func_INITAPI(   binary94   *MAXSOC,
                     IdentType  *IDENT,
                     picX       *SUBTASK,
                     binary98   *MAXSNO,
                     binary98   *ERRNO,
                     binary98s  *RETCODE)
{
   /* I am open to better ways to determine byte order, but this
   ** is what I am going with for now:  We will use ERRNO as an
   ** input variable for INITAPI.  We will instruct COBOL programmers
   ** to set ERRNO=1 before they call INITAPI.  If the the 1 is
   ** in the bit position that indicates reversed byte order
   ** then we will reverse the sense of Swap.
   **
   ** On the mainframe the ERRNO=1 will just be ignored.
   */

   int32_t MaxSoc;
   int MaxSNo;
   int32_t ErrNoIn = bin982int(ERRNO);
   
   if (ErrNoIn == 0x01000000)
   {
      /* we must be running with bytes reversed */
      Swap = !Swap;
   }
   
   MaxSoc = bin942int(MAXSOC);
   if (MaxSoc < 50)
   {
      MaxSoc = 50;
   }
   MaxSNo = MaxSoc - 1;

   PicXisEbcdic = LooksLikeEbcdic(SUBTASK);
   int2bin98(MAXSNO, MaxSNo);

   #ifdef LOG
   printf("%d: INITAPI(%d, [%s, %s], %s, %d, %d, %d)\n",
         getpid(), MaxSoc, "", "", "", MaxSNo, ErrNoIn, 0
         );
   #endif

   int2bin98s(RETCODE, 0);
}

static void func_INITAPIX(  binary94          *MAXSOC,
                     IdentType         *IDENT,
                     picX              *SUBTASK,
                     binary98          *MAXSNO,
                     binary98          *ERRNO,
                     binary98s         *RETCODE)
{
   /* When this is needed just duplicate INITAPI */
   notImplemented(ERRNO, RETCODE, "INITAPIX");
}

#ifndef HP
typedef void (*IOCTLProcessFunc)(int32_t s, 
                               unsigned int Command, 
                               pointer Input, 
                               pointer Output,
                               binary98 *ERRNO,
                               binary98s *RETCODE);

struct IOCTLCommandMatchPair
{
   uint32_t ExternalCommand;
   unsigned int InternalCommand;
   IOCTLProcessFunc IOCTLProcessFunc;
};

static void IOCTLFionbio(int32_t s, 
                  unsigned int Command, 
                  pointer Input, 
                  pointer Output,
                  binary98 *ERRNO,
                  binary98s *RETCODE)
{
   int Block = bin982int((binary98 *)Input);
   if (ioctl(s, Command, &Block) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }  
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void IOCTLFionRead(int32_t s, 
                  unsigned int Command, 
                  pointer Input, 
                  pointer Output,
                  binary98 *ERRNO,
                  binary98s *RETCODE)
{
   int BytesForRead;
   if (ioctl(s, Command, &BytesForRead) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }  
   else
   {
      #ifdef LOG
      printf("%d: IOCTL FIONREAD returned %d\n", getpid(), BytesForRead);
      #endif
      int2bin98((binary98 *)Output, BytesForRead);
      int2bin98s(RETCODE, 0);
   }
}

static void IOCTLSiocAtMark(int32_t s, 
                  unsigned int Command, 
                  pointer Input, 
                  pointer Output,
                  binary98 *ERRNO,
                  binary98s *RETCODE)
{
   int LefeData;
   if (ioctl(s, Command, &LefeData) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }  
   else
   {
      int2bin98((binary98 *)Output, LefeData);
      int2bin98s(RETCODE, 0);
   }
}

struct IFREQ
{
   picX NAME[16]; 
   binary94 FAMILY;
   binary94 PORT;
   binary98 ADDRESS;
   picX FILLER[8]; 
};

#ifdef NEVER


/* this is the structure from HP: */

struct  ifreq {
char    ifr_name[IFNAMSIZ];             /* if name, e.g. "en0" */
union {
		struct  sockaddr ifru_addr;
		struct  sockaddr ifru_dstaddr;
		struct  sockaddr ifru_broadaddr;
		short   ifru_flags;
		#if defined(__STDC_EXT__) || defined(__LP64__)
		uint64_t ifru_xflags;           /* Extended flags */
		#endif
		int     ifru_metric;
																caddr_t ifru_data;
																	} ifr_ifru;
																	#define ifr_addr        ifr_ifru.ifru_addr      /* address */
																	#define ifr_dstaddr     ifr_ifru.ifru_dstaddr   /* other end of p-to-p link */
																	#define ifr_broadaddr   ifr_ifru.ifru_broadaddr /* broadcast address */
																	#if defined(__STDC_EXT__) || defined(__LP64__)
																	#define ifr_xflags      ifr_ifru.ifru_xflags    /* extended flags */
																	#endif
																	#define ifr_flags       ifr_ifru.ifru_flags     /* flags */
																	#define ifr_metric      ifr_ifru.ifru_metric    /* metric */
																	#define ifr_mtu         ifr_ifru.ifru_metric    /* mtu */
																	#define ifr_index       ifr_ifru.ifru_metric    /* index */
																	#define ifr_data        ifr_ifru.ifru_data      /* for use by interface */
																	};
#endif

static void IOCTLSiocgIfAddr(int32_t s, 
                  unsigned int Command, 
                  pointer Input, 
                  pointer Output,
                  binary98 *ERRNO,
                  binary98s *RETCODE)
{
   struct IFREQ *IFREQ;
   struct ifreq IfReq;
   
   /* Bug how to convert string from cobol to c*/
   int i;
   IFREQ = (struct IFREQ *)Input;
   i = 0;
   while (i < 15)
   {
      if (IFREQ->NAME[i] == ' ')
      {
         break;
      }
      #ifdef HP
      IfReq.ifru_name[i] = IFREQ->NAME[i];
      #else
      IfReq.ifr_ifrn.ifrn_name[i] = IFREQ->NAME[i];
      #endif
      i++;
   }
      #ifdef HP
   IfReq.ifru_name[i] = '\0';
      #else
   IfReq.ifr_ifrn.ifrn_name[i] = '\0';
      #endif
   
   if (ioctl(s, Command, &IfReq, sizeof(IfReq)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }  
   else
   {
      if (Output != NULL)
      {
         IFREQ = (struct IFREQ *)Output;
         str2picX(IFREQ->NAME, 16, IfReq.ifr_ifrn.ifrn_name, strlen(IfReq.ifr_ifrn.ifrn_name));
         #ifdef OPEN_EZASOKET_IPV6
         #error "ERROR: need to figure out how to set address for v6"
         #else
         struct sockaddr_in *SocketAddr = (struct sockaddr_in *)&IfReq.ifr_ifru.ifru_addr;
         int2bin94(&IFREQ->FAMILY, SocketAddr->sin_family);
         int2bin94(&IFREQ->PORT, SocketAddr->sin_port);
         int2bin98(&IFREQ->ADDRESS, ntohl(SocketAddr->sin_addr.s_addr));
         #endif
         
      }
      int2bin98s(RETCODE, 0);
   }
}

static void IOCTLSiocgIfBrdAddr(int32_t s, 
                  unsigned int Command, 
                  pointer Input, 
                  pointer Output,
                  binary98 *ERRNO,
                  binary98s *RETCODE)
{
   struct IFREQ *IFREQ;
   struct ifreq IfReq;
   
   /* Bug how to convert string from cobol to c*/
   int i;
   IFREQ = (struct IFREQ *)Input;
   i = 0;
   while (i < 15)
   {
      if (IFREQ->NAME[i] == ' ')
      {
         break;
      }
      IfReq.ifr_ifrn.ifrn_name[i] = IFREQ->NAME[i];
      i++;
   }
   IfReq.ifr_ifrn.ifrn_name[i] = '\0';
   
   if (ioctl(s, Command, &IfReq, sizeof(IfReq)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }  
   else
   {
      if (Output != NULL)
      {
         IFREQ = (struct IFREQ *)Output;
         str2picX(IFREQ->NAME, 16, IfReq.ifr_ifrn.ifrn_name, strlen(IfReq.ifr_ifrn.ifrn_name));
         #ifdef OPEN_EZASOKET_IPV6
         #error "ERROR: need to figure out how to set address for v6"
         #else
         struct sockaddr_in *SocketAddr = (struct sockaddr_in *)&IfReq.ifr_ifru.ifru_broadaddr;
         int2bin94(&IFREQ->FAMILY, SocketAddr->sin_family);
         int2bin94(&IFREQ->PORT, SocketAddr->sin_port);
         int2bin98(&IFREQ->ADDRESS, ntohl(SocketAddr->sin_addr.s_addr));
         #endif
      }
      int2bin98s(RETCODE, 0);
   }
}

static void IOCTLSiocgIfConf(int32_t s, 
                     unsigned int Command, 
                     pointer Input, 
                     pointer Output,
                     binary98 *ERRNO,
                     binary98s *RETCODE)
{
   struct ifconf conf; 
   struct IFREQ *IFREQ;
   struct ifreq *IfReq;
   
   int i;
   int TotalSize;
   int32_t InterfaceCount;
   InterfaceCount = bin982int((binary98 *)Input);
   
   if (InterfaceCount % 32 != 0)
   {
      #ifdef LOG
      printf("%d: IOCTLSiocgIfConf: interface count %d is not correct\n",
         getpid(), InterfaceCount);
      #endif
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   InterfaceCount = InterfaceCount/32;
   
   /*Bug: it seems that SIOCGSIZIFCONF is not supported on linux,
   ** so i use the code from internet to do that.
   if (ioctl(s, SIOCGSIZIFCONF, &TotalSize) < 0)
   {
      #ifdef LOG
      printf("%d: IOCTLSiocgIfConf: Fail to get the total size\n", getpid());
      #endif
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
      return ;
   }  
   */
   
   /* use the input parameter directly
   int bsz = sizeof(struct ifreq);
   int prevsz = bsz;
   conf.ifc_req = NULL;
   conf.ifc_len = prevsz;
   do
   {
      conf.ifc_req=(struct ifreq *)realloc(conf.ifc_req, bsz);
      if (!conf.ifc_req)
      {
         #ifdef LOG
         printf("%d: IOCTLSiocgIfConf: Fail to allocate memory\n", getpid());
         #endif
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      conf.ifc_len = bsz;
      if (ioctl(s, SIOCGIFCONF, &conf) < 0)
      {
         int SaveErrNo = errno;
         int2bin98(ERRNO, SaveErrNo);
         int2bin98s(RETCODE, -1);
         return ;
      }
      if (prevsz == conf.ifc_len)
      {
         break;
      }
      else
      {
         bsz = bsz*2;
         prevsz = (0==conf.ifc_len? bsz : conf.ifc_len);
      }
   }while(1);
   conf.ifc_req=(struct ifreq *)realloc(conf.ifc_req, prevsz);
   */
   
   conf.ifc_len = InterfaceCount * sizeof(struct ifreq);
   conf.ifc_req = (struct ifreq *)malloc(conf.ifc_len);
   if (conf.ifc_ifcu.ifcu_req == NULL)
   {
      #ifdef LOG
      printf("%d: IOCTLSiocgIfConf: Fail to allocate memory\n", getpid());
      #endif
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   if (ioctl(s, Command, &conf) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      if (Output != NULL)
      {
         int RetInterfaceCount = conf.ifc_len/sizeof(struct ifreq);
         RetInterfaceCount = (RetInterfaceCount > InterfaceCount)?InterfaceCount:RetInterfaceCount;
         
         IFREQ = (struct IFREQ *)Output;
         IfReq = conf.ifc_ifcu.ifcu_req;
         for (i=0; i<RetInterfaceCount; i++)
         {
            str2picX(IFREQ->NAME, 16, IfReq->ifr_ifrn.ifrn_name, strlen(IfReq->ifr_ifrn.ifrn_name));
            #ifdef OPEN_EZASOKET_IPV6
            #error "ERROR: need to figure out how to set address for v6"
            #else
            struct sockaddr_in *SocketAddr = (struct sockaddr_in *)&IfReq->ifr_ifru.ifru_dstaddr;
            int2bin94(&IFREQ->FAMILY, SocketAddr->sin_family);
            int2bin94(&IFREQ->PORT, SocketAddr->sin_port);
            int2bin98(&IFREQ->ADDRESS, ntohl(SocketAddr->sin_addr.s_addr));
            #endif
            IFREQ++;
            IfReq++;
         }
      }
      int2bin98s(RETCODE, 0);
   }
   free(conf.ifc_ifcu.ifcu_req);
}

static void IOCTLSiocgIfDstAddr(int32_t s, 
                        unsigned int Command, 
                        pointer Input, 
                        pointer Output,
                        binary98 *ERRNO,
                        binary98s *RETCODE)
{
   struct IFREQ *IFREQ;
   struct ifreq IfReq;
   
   /* Bug: how to convert string from cobol to c */
   int i;
   IFREQ = (struct IFREQ *)Input;
   i = 0;
   while (i < 15)
   {
      if (IFREQ->NAME[i] == ' ')
      {
         break;
      }
      IfReq.ifr_ifrn.ifrn_name[i] = IFREQ->NAME[i];
      i++;
   }
   IfReq.ifr_ifrn.ifrn_name[i] = '\0';
   
   if (ioctl(s, Command, &IfReq, sizeof(IfReq)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }  
   else
   {
      if (Output != NULL)
      {
         IFREQ = (struct IFREQ *)Output;
         str2picX(IFREQ->NAME, 16, IfReq.ifr_ifrn.ifrn_name, strlen(IfReq.ifr_ifrn.ifrn_name));
         #ifdef OPEN_EZASOKET_IPV6
         #error "ERROR: need to figure out how to set address for v6"
         #else
         struct sockaddr_in *SocketAddr = (struct sockaddr_in *)&IfReq.ifr_ifru.ifru_dstaddr;
         int2bin94(&IFREQ->FAMILY, SocketAddr->sin_family);
         int2bin94(&IFREQ->PORT, SocketAddr->sin_port);
         int2bin98(&IFREQ->ADDRESS, ntohl(SocketAddr->sin_addr.s_addr));
         #endif
      }
      int2bin98s(RETCODE, 0);
   }
}


#ifndef SIOCGHOMEIF6
#define SIOCGHOMEIF6 0xC014F608
#endif

#ifndef SIOCGIFNAMEINDEX
#define SIOCGIFNAMEINDEX 0x4000F603
#endif

#ifndef SIOCTTLSCTL
#define SIOCTTLSCTL 0xC038D90B
#endif

struct IOCTLCommandMatchPair IOCTLCommandMatchPairs[] = 
{
   {0,                   0,                      NULL},
   {0x8004A77E,          FIONBIO,                IOCTLFionbio},
   {0x4004A77F,          FIONREAD,               IOCTLFionRead},
   {0x4004A707,          SIOCATMARK,             IOCTLSiocAtMark},
   {0xC020A70D,          SIOCGIFADDR,            IOCTLSiocgIfAddr},
   {0xC020A712,          SIOCGIFBRDADDR,         IOCTLSiocgIfBrdAddr},
   {0xC008A714,          SIOCGIFCONF,            IOCTLSiocgIfConf},
   {0xC020A70F,          SIOCGIFDSTADDR,         IOCTLSiocgIfDstAddr},
   
   {0xC014F608,          SIOCGHOMEIF6,           NULL},
   {0x4000F603,          SIOCGIFNAMEINDEX,       NULL},
   {0xC038D90B,          SIOCTTLSCTL,            NULL},
};

static struct IOCTLCommandMatchPair *IOCTLCommandToPair(uint32_t Command)
{
   int i;
   for (i=1;i <sizeof(IOCTLCommandMatchPairs)/sizeof(struct IOCTLCommandMatchPair)-1; i++)
   {
      if (IOCTLCommandMatchPairs[i].ExternalCommand == Command)
      {
         return &IOCTLCommandMatchPairs[i];
      }
   }
   return NULL;
}

#endif  /* get rid of IOCTL for HP because of ifr_ifru/ifr_ifrn name mismatch. */

static void func_IOCTL(binary94  *SOCKID,
                binary98  *COMMAND,
                pointer    REQARG,
                pointer    RETARG,
                binary98  *ERRNO,
                binary98s *RETCODE)
{
#ifndef HP
   struct IOCTLCommandMatchPair *CommandPair;
   uint32_t Command;
   Command = bin982int(COMMAND);
   CommandPair = IOCTLCommandToPair(Command);
   if (CommandPair == NULL)
   {
      #ifdef LOG
      printf("%d: IOCTL: unknown COMMAND %d\n", getpid(), Command);
      #endif
      int2bin98s(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   if (CommandPair->IOCTLProcessFunc == NULL)
   {
      #ifdef LOG
      printf("%d: IOCTL: COMMAND %d is not implemented\n", getpid(), Command);
      #endif
      int2bin98s(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   int32_t s = bin942int(SOCKID);
   CommandPair->IOCTLProcessFunc(s, CommandPair->InternalCommand, REQARG, RETARG, ERRNO, RETCODE);
#endif  /* get rid of IOCTL for HP because of ifr_ifru/ifr_ifrn name mismatch. */
}

static void func_LISTEN(binary94  *SOCKID,
                 binary98  *BACKLOG,
                 binary98  *ERRNO,
                 binary98s *RETCODE)
{
   int32_t s       = bin942int(SOCKID);
   int BackLog = bin982int(BACKLOG);

   #ifdef LOG
   printf("%d: LISTEN(%d, %d)\n", getpid(), s, BackLog);
   #endif

   if (listen(s, BackLog) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void func_NTOP(binary98       *NTOP_FAMILY,
               IpAddressType  *IP_ADDRESS,
               picX           *PRESENTABLE_ADDRESS,
               binary94       *PRESENTABLE_ADDRESS_LEN,
               binary98       *ERRNO,
               binary98s      *RETCODE)
{
   char IPAddressBuff[45+1];
   struct in_addr IPAddress;
   int32_t Family   = bin982int(NTOP_FAMILY);
   int32_t AddressLen;
   int32_t AddressFullLen;

   if ((Family != EZASOKET_AF_INET) && (Family != EZASOKET_AF_INET6))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   IPAddress.s_addr = htonl(bin982int(IP_ADDRESS));
   sprintf(IPAddressBuff, "%s", inet_ntoa(IPAddress));
   
   AddressLen = bin942int(PRESENTABLE_ADDRESS_LEN);
   AddressFullLen = strlen(IPAddressBuff);
   if (AddressFullLen > AddressLen)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   else
   {
      str2picX(PRESENTABLE_ADDRESS, AddressLen, IPAddressBuff, AddressFullLen);
      int2bin94(PRESENTABLE_ADDRESS_LEN, AddressFullLen);
      int2bin98s(RETCODE, 0);
   }
}

static void func_PTON(binary98       *FAMILY,
               picX           *PRESENTABLE_ADDRESS,
               binary94       *PRESENTABLE_ADDRESS_LEN,
               IpAddressType  *IP_ADDRESS,
               binary98       *ERRNO,
               binary98s      *RETCODE)
{
   char IPAddressBuff[45+1];
   struct in_addr Address;
   int32_t Family;
   int32_t AddressLen;

   Family = bin982int(FAMILY);
   if ((Family != EZASOKET_AF_INET) && (Family != EZASOKET_AF_INET6))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   AddressLen = bin942int(PRESENTABLE_ADDRESS_LEN);
   if (AddressLen > 45)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
   }
   
   memcpy(IPAddressBuff, PRESENTABLE_ADDRESS, AddressLen);
   IPAddressBuff[AddressLen] = '\0';
   if (inet_aton(IPAddressBuff, &Address) == 0)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98(IP_ADDRESS, ntohl(Address.s_addr));
      int2bin98s(RETCODE, 0);
   }
}

static void func_READ(binary94  *SOCKID,
               binary98       *NBYTE,
               picX           *BUF,
               binary98       *ERRNO,
               binary98s      *RETCODE)
{
   int32_t s = bin942int(SOCKID);
   int NByte = bin982int(NBYTE);
   char *Buf = BUF;

   int BytesRead;

   #ifdef LOG
   printf("%d: READ(%d, %x, %d)\n", getpid(), s, s, NByte);
   #endif
   /* BUG: this should be a blocking read: */
   if ((BytesRead = read(s, Buf, NByte)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesRead);
   }
}

static void func_READV(binary94   *SOCKID,
                iovType    *IOV,
                binary98   *IOVCNT,
                binary98   *ERRNO,
                binary98s  *RETCODE)
{
   int32_t s = bin942int(SOCKID);
   int IovCnt = bin982int(IOVCNT);

   struct iovec *IoVec;
   struct iovec *IoVecBase;
   int BytesRead;
   int i;

   #ifdef LOG
   printf("%d: READV(%d, %p, %d)\n", getpid(), s, IOV, IovCnt);
   #endif

   IoVecBase = (struct iovec *)malloc((sizeof(struct iovec)) * IovCnt);
   if (IoVecBase == NULL)
   {
      #ifdef LOG
      printf("%d: READV - Fail to allocate memory for structure iovec\n", getpid());
      #endif
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   IoVec = IoVecBase;

   for(i = 0; i < IovCnt; i++)
   {
      IoVec->iov_base = IOV->BUFFER_POINTER;
      IoVec->iov_len  = bin982int(&(IOV->BUFFER_LENGTH));
      IoVec++;
      IOV++;
   }
   if ((BytesRead = readv(s, IoVecBase, IovCnt)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesRead);
   }
   free(IoVecBase);
}

static void func_RECV(binary94  *SOCKID,
               binary98  *FLAGS,
               binary98  *NBYTE,
               picX      *BUF,
               binary98  *ERRNO,
               binary98s *RETCODE)
{
   int32_t s = bin942int(SOCKID);
   int32_t Flags = bin982int(FLAGS);
   int32_t NByte = bin982int(NBYTE);
   char *Buf = BUF;

   int BytesRead;

   #ifdef LOG
   printf("%d: RECV(%d, %x, %d)\n", getpid(), s, Flags, NByte);
   #endif
   if ((BytesRead = recv(s, Buf, NByte, Flags)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesRead);
   }
}

static void func_RECVFROM(binary94  *SOCKID,
                   binary98  *FLAGS,
                   binary98  *NBYTE,
                   picX      *BUF,
                   NameType  *NAME,
                   binary98  *ERRNO,
                   binary98s *RETCODE)
{
   int32_t Flags;
   int32_t s;
   int32_t BufferLength;
   struct sockaddr_in Address;
   struct sockaddr_in *PassAddress;
   socklen_t AddressLen;
   char *Buf;
  
   int BytesRead;
   
   s = bin942int(SOCKID);
   Flags = bin982int(FLAGS);
   BufferLength = bin982int(NBYTE);
   Buf = BUF;
   
   if (NAME != NULL)
   {
      int32_t Family   = bin942int(&(NAME->FAMILY));
      if (Family == EZASOKET_AF_INET)
      {
         Address.sin_family = AF_INET;
      }
      else if (Family == EZASOKET_AF_INET6)
      {
         Address.sin_family = AF_INET6;
      }
      else
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      Address.sin_port = htons(bin942int(&(NAME->PORT)));
      
      PassAddress = &Address;
      AddressLen = sizeof(struct sockaddr_in);
   }
   else
   {
      PassAddress = NULL;
      AddressLen = 0;
   }
   
   #ifdef LOG
   if (PassAddress)
   {
      printf("%d: RECVFROM(%d, %d, %d)\n", getpid(), s, Flags, BufferLength);
   }
   else
   {
      int32_t name_ip_addr = IP_ADDRESS2int(&(NAME->IP_ADDRESS));
      printf("%d: RECVFROM(%d, %d, %d, [%d, %d, %x | %x])\n", getpid(), s, Flags,BufferLength,
              Address.sin_family,
              Address.sin_port,
              Address.sin_addr.s_addr,
              name_ip_addr
      );
   }
   #endif
   
   if ((BytesRead = recvfrom(s, Buf, BufferLength, Flags, (struct sockaddr *)PassAddress, &AddressLen)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesRead);
   }
}

static void func_RECVMSG(binary94  *SOCKID,
                  MsgType   *MSG,
                  binary98  *FLAGS,
                  binary98  *ERRNO,
                  binary98s *RETCODE)
{
   int32_t Flags;
   int32_t s;
   struct iovec *IoVec;
   int i;
   struct msghdr MsgHeader;
   iovType *iovTypeBase;
   
   
   int BytesRead;

   s = bin942int(SOCKID);
   Flags = bin982int((binary98 *)FLAGS);
   
   if (MSG->NAME != NULL)
   {
      MsgHeader.msg_name = MSG->NAME;
      /* todo: check the input parameters */
   }
   else
   {
      MsgHeader.msg_name = NULL;
   }
   
   if (MSG->NAME_LEN != NULL)
   {
      MsgHeader.msg_namelen = bin982int((binary98 *)MSG->NAME_LEN);
   }
   else
   {
      MsgHeader.msg_namelen = 0;
   }
   
   if ((MSG->IOVCNT == NULL) || MSG->IOV == NULL)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return;
   }
   MsgHeader.msg_iovlen = bin982int((binary98 *)MSG->IOVCNT);
   iovTypeBase = (iovType *)MSG->IOV;
   #ifdef LOG
   printf("%d: RECVMSG(%d, %d, %d)\n", getpid(), s, Flags, (int32_t)MsgHeader.msg_iovlen);
   #endif
   
   MsgHeader.msg_iov = (struct iovec *)malloc((sizeof(struct iovec)) * MsgHeader.msg_iovlen);
   if (MsgHeader.msg_iov == NULL)
   {
      #ifdef LOG
      printf("%d: RECVMSG - fail to allocate memory for iovec\n", getpid());
      #endif
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   IoVec = MsgHeader.msg_iov;
   
   for(i = 0; i < MsgHeader.msg_iovlen; i++)
   {
      IoVec->iov_base = iovTypeBase->BUFFER_POINTER;
      IoVec->iov_len  = bin982int(&(iovTypeBase->BUFFER_LENGTH));
      IoVec++;
      iovTypeBase++;
   }
   MsgHeader.msg_control = MSG->ACCRIGHTS;
   if (MSG->ACCRLEN != NULL)
   {
      MsgHeader.msg_controllen = bin982int((binary98 *)MSG->ACCRLEN);
   }
   else
   {
      MsgHeader.msg_controllen = 0;
   }
   
   /* Bug: how to set msg_flags */
   if ((BytesRead = recvmsg(s, &MsgHeader, Flags)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesRead);
   }
   free(MsgHeader.msg_iov);
}

int MaxSocToNumBytes(int MaxSoc)
{
   return((MaxSoc/8)+1);
}

void SetToMask(picX *MASK, fd_set *pSet, int MaxSoc)
{
   int Mask;
   int i;
   Mask = 0;
   for (i = 0; i < MaxSoc; i++)
   {
      if (FD_ISSET(i+1, pSet))
      {
         Mask |= 0x1<<(i%32);
      }
      if ((i != 0) && ((i%32) == 0))
      {
         int2bin98((binary98 *)MASK, Mask);
         Mask = 0;
         MASK += 4;  /* change the pointer by 4 bytes */
      }
   }
}

void MaskToSet(fd_set *pSet, picX *MASK, int MaxSoc)
{
   fd_set Set;
   int Mask;
   int i;
   FD_ZERO(&Set);
   for (i = 0; i < MaxSoc; i++)
   {
      if ((i%32) == 0)
      {
         Mask = bin982int((binary98 *)MASK);
         MASK += 4;  /* change the pointer by 4 bytes */
      }
      if (Mask & 0x1<<(i%32))
      {
         FD_SET(i+1, &Set);
      }
   }
   *pSet = Set;
}

void printfdset(const char *Prefix, fd_set *pSet, int MaxSoc)
{
   int i;
   printf("%s: ", Prefix);
   if (MaxSoc > 255)
   {
      printf("ASSERTION: MaxSoc exceeds normal limits\n");
      exit(1);
   }
   for (i = MaxSoc; i > 0; i--)
   {
      if ((i != MaxSoc) && ((i%4) == 0))
      {
         printf(" ");
      }
      if (FD_ISSET(i, pSet))
      {
         printf("1");
      }
      else
      {
         printf("0");
      }
   }
   printf("\n");
}

static void func_SELECT( binary98  *MAXSOC,
                  TimeOut   *TIMEOUT,
                  picX      *RSNDMSK,
                  picX      *WSNDMSK,
                  picX      *ESNDMSK,
                  picX      *RRETMSK,
                  picX      *WRETMSK,
                  picX      *ERETMSK,
                  binary98  *ERRNO,
                  binary98s *RETCODE)
{
   fd_set readfds;
   fd_set writefds;
   fd_set exceptfds;
   struct timeval tv;
   struct timeval *tvp;
   int RtnVal;

   int32_t MaxSoc  = bin982int(MAXSOC);

   tv.tv_sec  = bin982int(&(TIMEOUT->TIMEOUT_SECONDS));
   if (tv.tv_sec < 0)
   {
      tvp = NULL;
   }
   else
   {
      tv.tv_usec = bin982int(&(TIMEOUT->TIMEOUT_MICROSEC));
      tvp = &tv;
   }

   #ifdef LOG
   printf("%d: SELECT(%d, r, w, x, [%d.%d])\n", getpid(), MaxSoc, (int32_t)tv.tv_sec, (int32_t)tv.tv_usec);
   #endif

   if (MaxSoc > FD_SETSIZE)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return;
   }

   MaskToSet(&readfds,   RSNDMSK, MaxSoc);
   MaskToSet(&writefds,  WSNDMSK, MaxSoc);
   MaskToSet(&exceptfds, ESNDMSK, MaxSoc);

   printfdset("ri", &readfds,   MaxSoc);
   printfdset("wi", &writefds,  MaxSoc);
   printfdset("ei", &exceptfds, MaxSoc);

   if ((RtnVal = select(MaxSoc, &readfds, &writefds, &exceptfds, tvp)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
   }
   else
   {
      SetToMask(RRETMSK, &readfds,   MaxSoc);
      SetToMask(WRETMSK, &writefds,  MaxSoc);
      SetToMask(ERETMSK, &exceptfds, MaxSoc);
      printfdset("ro", &readfds,   MaxSoc);
      printfdset("wo", &writefds,  MaxSoc);
      printfdset("eo", &exceptfds, MaxSoc);
   }
   int2bin98s(RETCODE, RtnVal);
}

static void func_SELECTEX( binary98  *MAXSOC,
                  TimeOut   *TIMEOUT,
                  picX      *RSNDMSK,
                  picX      *WSNDMSK,
                  picX      *ESNDMSK,
                  picX      *RRETMSK,
                  picX      *WRETMSK,
                  picX      *ERETMSK,
                  pointer    SELECB,
                  binary98  *ERRNO,
                  binary98s *RETCODE)
{
   fd_set readfds;
   fd_set writefds;
   fd_set exceptfds;
   struct timeval tv;
   struct timeval *tvp;
   int RtnVal;

   int32_t MaxSoc  = bin982int(MAXSOC);

   /* Bug :ECB is not implemented,
   ** and now it's the same as SELECT
   **/
   if (SELECB != NULL)
   {
      #ifdef LOG
      printf("%d: SELECTEX ECB field is not supported now\n", getpid());
      #endif
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }

   tv.tv_sec  = bin982int(&(TIMEOUT->TIMEOUT_SECONDS));
   if (tv.tv_sec < 0)
   {
      tvp = NULL;
   }
   else
   {
      tv.tv_usec = bin982int(&(TIMEOUT->TIMEOUT_MICROSEC));
      tvp = &tv;
   }

   #ifdef LOG
   printf("%d: SELECTEX(%d, r, w, x, [%d.%d])\n", getpid(), MaxSoc, (int32_t)tv.tv_sec, (int32_t)tv.tv_usec);
   #endif

   if (MaxSoc > FD_SETSIZE)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return;
   }

   MaskToSet(&readfds,   RSNDMSK, MaxSoc);
   MaskToSet(&writefds,  WSNDMSK, MaxSoc);
   MaskToSet(&exceptfds, ESNDMSK, MaxSoc);

   printfdset("ri", &readfds,   MaxSoc);
   printfdset("wi", &writefds,  MaxSoc);
   printfdset("ei", &exceptfds, MaxSoc);

   if ((RtnVal = select(MaxSoc, &readfds, &writefds, &exceptfds, tvp)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
   }
   else
   {
      SetToMask(RRETMSK, &readfds,   MaxSoc);
      SetToMask(WRETMSK, &writefds,  MaxSoc);
      SetToMask(ERETMSK, &exceptfds, MaxSoc);
      printfdset("ro", &readfds,   MaxSoc);
      printfdset("wo", &writefds,  MaxSoc);
      printfdset("eo", &exceptfds, MaxSoc);
   }
   int2bin98s(RETCODE, RtnVal);
}


static void func_SEND(binary94  *SOCKID,
               binary98  *FLAGS,
               binary98  *NBYTE,
               picX      *BUF,
               binary98  *ERRNO,
               binary98s *RETCODE)
{
   int32_t s = bin942int(SOCKID);
   int32_t Flags = bin982int(FLAGS);
   int32_t NByte = bin982int(NBYTE);
   char *Buf = BUF;

   int BytesWriten;
   
/*   #if MSG_DONTROUTE != 4
**   #error "MSG_DONTROUTE is not 4.  4 is used by EZASOKET"
**   #endif
**   #if MSG_OOB != 1
**   #error "MSG_OOB is not 1.  1 is used by EZASOKET"
**   #endif
*/

   #ifdef LOG
   printf("%d: SEND(%d, %d, %d)\n", getpid(), s, Flags, NByte);
   #endif
   if ((BytesWriten = send(s, Buf, NByte, Flags)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesWriten);
   }
}

static void func_SENDMSG(binary94  *SOCKID,
                  binary98  *FLAGS,
                  MsgType   *MSG,
                  binary98  *ERRNO,
                  binary98s *RETCODE)
{
   int32_t Flags;
   int32_t s;
   struct iovec *IoVec;
   int i;
   struct msghdr MsgHeader;
   iovType *iovTypeBase;
  
   int BytesWriten;
   s = bin942int(SOCKID);
   Flags = bin982int((binary98 *)FLAGS);
   
   if (MSG->NAME != NULL)
   {
      MsgHeader.msg_name = MSG->NAME;
      /* todo: check the input parameters */
   }
   else
   {
      MsgHeader.msg_name = NULL;
   }
   
   if (MSG->NAME_LEN != NULL)
   {
      MsgHeader.msg_namelen = bin982int((binary98 *)MSG->NAME_LEN);
   }
   else
   {
      MsgHeader.msg_namelen = 0;
   }
   
   if ((MSG->IOVCNT == NULL) || MSG->IOV == NULL)
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return;
   }
   MsgHeader.msg_iovlen = bin982int((binary98 *)MSG->IOVCNT);
   iovTypeBase = (iovType *)MSG->IOV;
   #ifdef LOG
   printf("%d: SENDMSG(%d, %d, %d)\n", getpid(), s, Flags, (int32_t)MsgHeader.msg_iovlen);
   #endif
   
   MsgHeader.msg_iov = malloc((sizeof(struct iovec)) * MsgHeader.msg_iovlen);
   if (MsgHeader.msg_iov == NULL)
   {
      #ifdef LOG
      printf("%d: SENDMSG - fail to allocate memory for iovec\n", getpid());
      #endif
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   IoVec = MsgHeader.msg_iov;
   for(i = 0; i < MsgHeader.msg_iovlen; i++)
   {
      IoVec->iov_base = iovTypeBase->BUFFER_POINTER;
      IoVec->iov_len  = bin982int(&(iovTypeBase->BUFFER_LENGTH));
      IoVec++;
      iovTypeBase++;
   }
   
   MsgHeader.msg_control = MSG->ACCRIGHTS;

   if (MSG->ACCRLEN != NULL)
   {
      MsgHeader.msg_controllen = bin982int((binary98 *)MSG->ACCRLEN);
   }
   else
   {
      MsgHeader.msg_controllen = 0;
   }
   
   /* Bug: how to set msg_flags */
   if ((BytesWriten = sendmsg(s, &MsgHeader, Flags)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesWriten);
   }
   
   free(MsgHeader.msg_iov);
}

static void func_SENDTO(binary94  *SOCKID,
                 binary98  *FLAGS,
                 binary98  *NBYTE,
                 picX      *BUF,
                 NameType  *NAME,
                 binary98  *ERRNO,
                 binary98s *RETCODE)
{
   int32_t Flags;
   int32_t s;
   int32_t BufferLength;
   struct sockaddr_in Address;
   struct sockaddr_in *PassAddress;
   socklen_t AddressLen;
   char *Buf;
  
   int BytesWriten;
   
   s = bin942int(SOCKID);
   Flags = bin982int(FLAGS);
   BufferLength = bin982int(NBYTE);
   Buf = BUF;
   if (NAME != NULL)
   {
      int32_t Family   = bin942int(&(NAME->FAMILY));
      if (Family == EZASOKET_AF_INET)
      {
         Address.sin_family = AF_INET;
      }
      else if (Family == EZASOKET_AF_INET6)
      {
         Address.sin_family = AF_INET6;
      }
      else
      {
         int2bin98(ERRNO, EINVAL);
         int2bin98s(RETCODE, -1);
         return ;
      }
      Address.sin_port = htons(bin942int(&(NAME->PORT)));
      
      PassAddress = &Address;
      AddressLen = sizeof(struct sockaddr_in);
   }
   else
   {
      PassAddress = NULL;
      AddressLen = 0;
   }
   
   #ifdef LOG
   if (PassAddress)
   {
      printf("%d: SENDTO(%d, %d, %d)\n", getpid(), s, Flags, BufferLength);
   }
   else
   {
      int32_t name_ip_addr = IP_ADDRESS2int(&(NAME->IP_ADDRESS));
      printf("%d: SENDTO(%d, %d, %d, [%d, %d, %x | %x])\n",
              getpid(), s, Flags,BufferLength,
              Address.sin_family,
              Address.sin_port,
              Address.sin_addr.s_addr,
              name_ip_addr
      );
   }
   #endif
   
   if ((BytesWriten = sendto(s, Buf, BufferLength, Flags, (const struct sockaddr *)PassAddress, AddressLen)) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesWriten);
   }
}

static void func_SETSOCKOPT(binary94  *SOCKID,
                     binary98  *OPTNAME,
                     pointer   OPTVAL,
                     binary98  *OPTLEN,
                     binary98  *ERRNO,
                     binary98s *RETCODE)
{
   int32_t s;
   socklen_t OptLen;
   uint32_t OptName;
   struct OptionMatchPair *Option;
   
   OptName = bin982int(OPTNAME);
   #ifdef LOG
   printf("%d: SETSOCKOPT %d \n", getpid(), OptName);
   #endif
   Option = ProcessOptionName(OptName);
   if ((Option == NULL) || (Option->ProcessOptionForInputFunc == NULL))
   {
      int2bin98(ERRNO, EINVAL);
      int2bin98s(RETCODE, -1);
      return ;
   }
   
   s = bin942int(SOCKID);
   OptLen = (socklen_t)bin982int(OPTLEN);
   #ifdef LOG
   printf("%d: SETSOCKOPT %d %d %p\n", getpid(), OptName, Option->InternalOption, OPTVAL);
   #endif
   Option->ProcessOptionForInputFunc(s,
                                    Option->Level, 
                                    Option->InternalOption,
                                    (void *)OPTVAL, 
                                    OptLen,
                                    ERRNO,
                                    RETCODE
                                    );
}

static void func_SHUTDOWN(binary94  *SOCKID,
                   binary98  *HOW,
                   binary98  *ERRNO,
                   binary98s *RETCODE)
{
   int32_t s = bin942int(SOCKID);
   int32_t How   = bin982int(HOW);

/* #if SHUT_RD != 0
** #error "SHUT_RD is not 0"
** #endif
** #if SHUT_WR != 1
** #error "SHUT_WR is not 1"
** #endif
** #if SHUT_RDWR != 2
** #error "SHUT_RDWR is not 2"
** #endif
*/

   if (shutdown(s, How) < 0)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, 0);
   }
}

static void func_SOCKET(binary98  *AF,
                 binary98  *SOCTYPE,
                 binary98  *PROTO,
                 binary98  *ERRNO,
                 binary98s *RETCODE)
{
   int32_t s;

   int32_t Af = bin982int(AF);
   int32_t SocType = bin982int(SOCTYPE);
   int32_t Proto = bin982int(PROTO);

   #ifdef LOG
   printf("%d: SOCKET(%d, %d, %d)\n", getpid(), Af, SocType, Proto);
   #endif
   if (Af == EZASOKET_AF_INET)
   {
      Af = AF_INET;
   }
   else if (Af == EZASOKET_AF_INET6)
   {
      #ifdef AF_INET6
         Af = AF_INET6;
      #else
         int2bin98(ERRNO, EAFNOSUPPORT);
         int2bin98s(RETCODE, -1);
         return;
      #endif
   }
   else
   {
      int2bin98(ERRNO, EAFNOSUPPORT);
      int2bin98s(RETCODE, -1);
      return;
   }
   if (SocType == 1)
   {
      SocType = SOCK_STREAM;
   }
   else if (SocType == 2)
   {
      SocType = SOCK_DGRAM;
   }
   else
   {
      int2bin98(ERRNO, EPROTOTYPE);
      int2bin98s(RETCODE, -1);
      return;
   }
   if (Proto != 0)
   {
      /* I do not know how to implement protocol with confidence
      ** so I am just not going to do anything.  It seems that socket()
      ** will accept 0 for a protocol and _probably_ does the right
      ** thing so I am just going to go with that.  
      */
      printf("%d: WARNING: non-zero protocol passed to SOCKET\n", getpid());
   }

   if ((s = socket(Af, SocType, Proto)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
   }
   int2bin98s(RETCODE, s);
}

static void func_TAKESOCKET(binary94   *SOCRECV,
                           ClientType *CLIENT,
                           binary98   *ERRNO,
                           binary98s  *RETCODE)
{
   int32_t s = bin942int(SOCRECV);
   TakeSoc(s, CLIENT, ERRNO, RETCODE);
}

static void func_TERMAPI(void)
{
   /* BUG: TERMAPI not implemented */
   #ifdef LOG
   printf("%d: TERMAPI()\n", getpid());
   #endif
}

static void func_WRITE(binary94  *SOCKID,
                binary98  *NBYTE,
                picX      *BUF,
                binary98  *ERRNO,
                binary98s *RETCODE)
{
   int32_t s       = bin942int(SOCKID);
   int32_t NByte   = bin982int(NBYTE);
   char *Buf   = BUF;

   int BytesWriten;

   #ifdef LOG
   printf("%d: WRITE(%d, %d)\n", getpid(), s, NByte);
   #endif
   if ((BytesWriten = write(s, Buf, NByte)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesWriten);
   }
}

static void func_WRITEV(binary94  *SOCKID,
                 iovType   *IOV,
                 binary98  *IOVCNT,
                 binary98  *ERRNO,
                 binary98s *RETCODE)
{
   int32_t s      = bin942int(SOCKID);
   uint32_t IovCnt = bin982int(IOVCNT);

   struct iovec *IoVec;
   struct iovec *IoVecBase;
   int BytesWriten;
   int i;

   #ifdef LOG
   printf("%d: WRITEV(%d, %p, %d)\n", getpid(), s, IOV, IovCnt);
   #endif

   IoVecBase = (struct iovec *)malloc((sizeof(struct iovec)) * IovCnt);
   if (IoVecBase == NULL)
   {
      #ifdef LOG
      printf("%d: WRITEV - fail to allocate memory for iovec\n", getpid());
      #endif
      return ;
   }
   IoVec = IoVecBase;

   if (IovCnt > 255)
   {
      printf("ASSERTION: IovCnt exceeds normal limits\n");
      exit(1);
   }

   for(i = 0; i < IovCnt; i++)
   {
      IoVec->iov_base = IOV->BUFFER_POINTER;
      IoVec->iov_len  = bin982int(&(IOV->BUFFER_LENGTH));
      IoVec++;
      IOV++;
   }
   if ((BytesWriten = writev(s, IoVecBase, IovCnt)) == -1)
   {
      int SaveErrNo = errno;
      int2bin98(ERRNO, SaveErrNo);
      int2bin98s(RETCODE, -1);
   }
   else
   {
      int2bin98s(RETCODE, BytesWriten);
   }
   free(IoVecBase);
}


enum SocketCommands
{
   SOKET_UNKNOWN,        /* 0 */
   SOKET_ACCEPT,         /* 1 */
   SOKET_BIND,           /* 2 */
   SOKET_CLOSE,          /* 3 */
   SOKET_CONNECT,        /* 4 */
   SOKET_FCNTL,          /* 5 */
   SOKET_FREEADDRINFO,   /* 6 */
   SOKET_GETADDRINFO,    /* 7 */
   SOKET_GETCLIENTID,    /* 8 */
   SOKET_GETHOSTBYADDR,  /* 9 */
   SOKET_GETHOSTBYNAME,  /* 10 */
   SOKET_GETHOSTID,      /* 11 */
   SOKET_GETHOSTNAME,    /* 12 */
   SOKET_GETNAMEINFO,    /* 13 */
   SOKET_GETPEERNAME,    /* 14 */
   SOKET_GETSOCKNAME,    /* 15 */
   SOKET_GETSOCKOPT,     /* 16 */
   SOKET_GIVESOCKET,     /* 17 */
   SOKET_INITAPI,        /* 18 */
   SOKET_INITAPIX,       /* 19 */
   SOKET_IOCTL,          /* 20 */
   SOKET_LISTEN,         /* 21 */
   SOKET_NTOP,           /* 22 */
   SOKET_PTON,           /* 23 */
   SOKET_READ,           /* 24 */
   SOKET_READV,          /* 25 */
   SOKET_RECV,           /* 26 */
   SOKET_RECVFROM,       /* 27 */
   SOKET_RECVMSG,        /* 28 */
   SOKET_SELECT,         /* 29 */
   SOKET_SELECTEX,       /* 30 */
   SOKET_SEND,           /* 31 */
   SOKET_SENDMSG,        /* 32 */
   SOKET_SENDTO,         /* 33 */
   SOKET_SETSOCKOPT,     /* 34 */
   SOKET_SHUTDOWN,       /* 35 */
   SOKET_SOCKET,         /* 36 */
   SOKET_TAKESOCKET,     /* 37 */
   SOKET_TERMAPI,        /* 38 */
   SOKET_WRITE,          /* 39 */
   SOKET_WRITEV,         /* 40 */
};

// static const char const *SocketCommandNames[] = 
#ifdef HP
static const char * SocketCommandNames[] = 
#else
static const char const * SocketCommandNames[] = 
#endif
{
   "                ",   /* 0 */
   "ACCEPT          ",   /* 1 */
   "BIND            ",   /* 2 */
   "CLOSE           ",   /* 3 */
   "CONNECT         ",   /* 4 */
   "FCNTL           ",   /* 5 */
   "FREEADDRINFO    ",   /* 6 */
   "GETADDRINFO     ",   /* 7 */
   "GETCLIENTID     ",   /* 8 */
   "GETHOSTBYADDR   ",   /* 9 */
   "GETHOSTBYNAME   ",   /* 10 */
   "GETHOSTID       ",   /* 11 */
   "GETHOSTNAME     ",   /* 12 */
   "GETNAMEINFO     ",   /* 13 */
   "GETPEERNAME     ",   /* 14 */
   "GETSOCKNAME     ",   /* 15 */
   "GETSOCKOPT      ",   /* 16 */
   "GIVESOCKET      ",   /* 17 */
   "INITAPI         ",   /* 18 */
   "INITAPIX        ",   /* 19 */
   "IOCTL           ",   /* 20 */
   "LISTEN          ",   /* 21 */
   "NTOP            ",   /* 22 */
   "PTON            ",   /* 23 */
   "READ            ",   /* 24 */
   "READV           ",   /* 25 */
   "RECV            ",   /* 26 */
   "RECVFROM        ",   /* 27 */
   "RECVMSG         ",   /* 28 */
   "SELECT          ",   /* 29 */
   "SELECTEX        ",   /* 30 */
   "SEND            ",   /* 31 */
   "SENDMSG         ",   /* 32 */
   "SENDTO          ",   /* 33 */
   "SETSOCKOPT      ",   /* 34 */
   "SHUTDOWN        ",   /* 35 */
   "SOCKET          ",   /* 36 */
   "TAKESOCKET      ",   /* 37 */
   "TERMAPI         ",   /* 38 */
   "WRITE           ",   /* 39 */
   "WRITEV          ",   /* 40 */
   0
};

// 77  RESPONSE          PIC 9(9) COMP.                        
// 77  TASK-FLAG         PIC X(1) VALUE '0'.                   
// 77  TAKE-SOCKET       PIC 9(8) COMP.                        
// 77  SOCKID            PIC 9(4) COMP.                        
// 77  SOCKID-FWD        PIC 9(8) COMP.                        
// 77  ERRNO             PIC 9(8) COMP.                        
// 77  RETCODE           PIC S9(8) COMP.                       
// 77  AF-INET           PIC 9(8) COMP VALUE 2.                
// 01  TCP-BUF.                                                
//     05 TCP-BUF-H      PIC X(3) VALUE IS SPACES.             
//     05 TCP-BUF-DATA   PIC X(197) VALUE IS SPACES.           
// 77  TCPLENG           PIC 9(8) COMP.                        
// 77  RECV-FLAG         PIC 9(8) COMP.                        
// 77  CLENG             PIC 9(4) COMP.                        
// 77  CNT               PIC 9(4) COMP.       

static socketFunction socketFunctions[] =
{
   (socketFunction)func_UNKNOWN,       /* 0 */
   (socketFunction)func_ACCEPT,        /* 1 */
   (socketFunction)func_BIND,          /* 2 */
   (socketFunction)func_CLOSE,         /* 3 */
   (socketFunction)func_CONNECT,       /* 4 */
   (socketFunction)func_FCNTL,         /* 5 */
   (socketFunction)func_FREEADDRINFO,  /* 6 */
   (socketFunction)func_GETADDRINFO,   /* 7 */
   (socketFunction)func_GETCLIENTID,   /* 8 */
   (socketFunction)func_GETHOSTBYADDR, /* 9 */
   (socketFunction)func_GETHOSTBYNAME, /* 10 */
   (socketFunction)func_GETHOSTID,     /* 11 */
   (socketFunction)func_GETHOSTNAME,   /* 12 */
   (socketFunction)func_GETNAMEINFO,   /* 13 */
   (socketFunction)func_GETPEERNAME,   /* 14 */
   (socketFunction)func_GETSOCKNAME,   /* 15 */
   (socketFunction)func_GETSOCKOPT,    /* 16 */
   (socketFunction)func_GIVESOCKET,    /* 17 */
   (socketFunction)func_INITAPI,       /* 18 */
   (socketFunction)func_INITAPIX,      /* 19 */
   (socketFunction)func_IOCTL,         /* 20 */
   (socketFunction)func_LISTEN,        /* 21 */
   (socketFunction)func_NTOP,          /* 22 */
   (socketFunction)func_PTON,          /* 23 */
   (socketFunction)func_READ,          /* 24 */
   (socketFunction)func_READV,         /* 25 */
   (socketFunction)func_RECV,          /* 26 */
   (socketFunction)func_RECVFROM,      /* 27 */
   (socketFunction)func_RECVMSG,       /* 28 */
   (socketFunction)func_SELECT,        /* 29 */
   (socketFunction)func_SELECTEX,      /* 30 */
   (socketFunction)func_SEND,          /* 31 */
   (socketFunction)func_SENDMSG,       /* 32 */
   (socketFunction)func_SENDTO,        /* 33 */
   (socketFunction)func_SETSOCKOPT,    /* 34 */
   (socketFunction)func_SHUTDOWN,      /* 35 */
   (socketFunction)func_SOCKET,        /* 36 */
   (socketFunction)func_TAKESOCKET,    /* 37 */
   (socketFunction)func_TERMAPI,       /* 38 */
   (socketFunction)func_WRITE,         /* 39 */
   (socketFunction)func_WRITEV,        /* 40 */
};

static int socketFunctionArgCount[] =
{
   0,  /* 0  UNKNOWN */
   4,  /* 1  ACCEPT */
   4,  /* 2  BIND */
   3,  /* 3  CLOSE */
   4,  /* 4  CONNECT */
   5,  /* 5  FCNTL */
   3,  /* 6  FREEADDRINFO */
   9,  /* 7  GETADDRINFO */
   3,  /* 8  GETCLIENTID */
   3,  /* 9  GETHOSTBYADDR */
   4,  /* 10 GETHOSTBYNAME */
   1,  /* 11 GETHOSTID */
   4,  /* 12 GETHOSTNAME */
   9,  /* 13 GETNAMEINFO */
   4,  /* 14 GETPEERNAME */
   4,  /* 15 GETSOCKNAME */
   6,  /* 16 GETSOCKOPT */
   4,  /* 17 GIVESOCKET */
   6,  /* 18 INITAPI */
   6,  /* 19 INITAPIX */
   6,  /* 20 IOCTL */
   4,  /* 21 LISTEN */
   6,  /* 22 NTOP */
   6,  /* 23 PTON */
   5,  /* 24 READ */
   5,  /* 25 READV */
   6,  /* 26 RECV */
   7,  /* 27 RECVFROM */
   5,  /* 28 RECVMSG */
   10, /* 29 SELECT */
   11, /* 30 SELECTEX */
   6,  /* 31 SEND */
   5,  /* 32 SENDMSG */
   7,  /* 33 SENDTO */
   6,  /* 34 SETSOCKOPT */
   4,  /* 35 SHUTDOWN */
   5,  /* 36 SOCKET */
   4,  /* 37 TAKESOCKET */
   0,  /* 38 TERMAPI */
   5,  /* 39 WRITE */
   5,  /* 40 WRITEV */
};



int EZASOKET(const char SocketCommand[16],
             void *one,
             void *two,
             void *three,
             void *four,
             void *five,
             void *six,
             void *seven,
             void *eight,
             void *nine,
             void *ten,
             void *eleven
            )
{
   enum SocketCommands sc;
   int argcount;

   sc = listIndex(SocketCommand, SocketCommandNames, 16);
   argcount = socketFunctionArgCount[sc];

   switch (argcount)
   {
   case 0:
      ((voidFunction)socketFunctions[sc])();
      break;
   case 1:
      socketFunctions[sc](one);
      break;
   case 2:
      socketFunctions[sc](one, two);
      break;
   case 3:
      socketFunctions[sc](one, two, three);
      break;
   case 4:
      socketFunctions[sc](one, two, three, four);
      break;
   case 5:
      socketFunctions[sc](one, two, three, four, five);
      break;
   case 6:
      socketFunctions[sc](one, two, three, four, five, six);
      break;
   case 7:
      socketFunctions[sc](one, two, three, four, five, six, seven);
      break;
   case 8:
      socketFunctions[sc](one, two, three, four, five, six, seven, eight);
      break;
   case 9:
      socketFunctions[sc](one, two, three, four, five, six, seven, eight, nine);
      break;
   case 10:
      socketFunctions[sc](one, two, three, four, five, six, seven, eight, nine, ten);
      break;
   case 11:
      socketFunctions[sc](one, two, three, four, five, six, seven, eight, nine, ten, eleven);
      break;
   default:
      /* need assertion check here */
      break;
   }

   return 0;
}

static const unsigned char Ascii2Ebcdic[256] =
{
   0x00,0x01,0x02,0x03,0x37,0x2D,0x2E,0x2F,0x16,0x05,0x25,0x0B,0x0C,0x0D,0x0E,0x0F,
   0x10,0x11,0x12,0x13,0x3C,0x3D,0x32,0x26,0x18,0x19,0x3F,0x27,0x22,0x1D,0x35,0x1F,
   0x40,0x5A,0x7F,0x7B,0x5B,0x6C,0x50,0x7D,0x4D,0x5D,0x5C,0x4E,0x6B,0x60,0x4B,0x61,
   0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0x7A,0x5E,0x4C,0x7E,0x6E,0x6F,
   0x7C,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6,
   0xD7,0xD8,0xD9,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xAD,0xE0,0xBD,0x5F,0x6D,
   0x79,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x91,0x92,0x93,0x94,0x95,0x96,
   0x97,0x98,0x99,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xC0,0x4F,0xD0,0xA1,0x07,
   0x00,0x01,0x02,0x03,0x37,0x2D,0x2E,0x2F,0x16,0x05,0x25,0x0B,0x0C,0x0D,0x0E,0x0F,
   0x10,0x11,0x12,0x13,0x3C,0x3D,0x32,0x26,0x18,0x19,0x3F,0x27,0x22,0x1D,0x35,0x1F,
   0x40,0x5A,0x7F,0x7B,0x5B,0x6C,0x50,0x7D,0x4D,0x5D,0x5C,0x4E,0x6B,0x60,0xAF,0x61,
   0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0x7A,0x5E,0x4C,0x7E,0x6E,0x6F, 
   0x7C,0xC1,0xC2,0xC3,0xC4,0xC5,0xC6,0xC7,0xC8,0xC9,0xD1,0xD2,0xD3,0xD4,0xD5,0xD6, 
   0xD7,0xD8,0xD9,0xE2,0xE3,0xE4,0xE5,0xE6,0xE7,0xE8,0xE9,0xAD,0xE0,0xBD,0x5F,0x6D, 
   0x79,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x91,0x92,0x93,0x94,0x95,0x96, 
   0x97,0x98,0x99,0xA2,0xA3,0xA4,0xA5,0xA6,0xA7,0xA8,0xA9,0xC0,0x4F,0xD0,0xA1,0x07
};

static const unsigned char Ebcdic2Ascii[256] =
{
   0x00,0x01,0x02,0x03,0x1A,0x09,0x1A,0x7F,0x1A,0x1A,0x1A,0x0B,0x0C,0x0D,0x0E,0x0F,
   0x10,0x11,0x12,0x13,0x1A,0x0A,0x08,0x1A,0x18,0x19,0x1A,0x1A,0x1C,0x1D,0x1E,0x1F,
   0x1A,0x1A,0x1C,0x1A,0x1A,0x0A,0x17,0x1B,0x1A,0x1A,0x1A,0x1A,0x1A,0x05,0x06,0x07,
   0x1A,0x1A,0x16,0x1A,0x1A,0x1E,0x1A,0x04,0x1A,0x1A,0x1A,0x1A,0x14,0x15,0x1A,0x1A,
   0x20,0xA6,0xE1,0x80,0xEB,0x90,0x9F,0xE2,0xAB,0x8B,0x9B,0x2E,0x3C,0x28,0x2B,0x7C,
   0x26,0xA9,0xAA,0x9C,0xDB,0xA5,0x99,0xE3,0xA8,0x9E,0x21,0x24,0x2A,0x29,0x3B,0x5E,
   0x2D,0x2F,0xDF,0xDC,0x9A,0xDD,0xDE,0x98,0x9D,0xAC,0xBA,0x2C,0x25,0x5F,0x3E,0x3F,
   0xD7,0x88,0x94,0xB0,0xB1,0xB2,0xFC,0xD6,0xFB,0x60,0x3A,0x23,0x40,0x27,0x3D,0x22,
   0xF8,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x96,0xA4,0xF3,0xAF,0xAE,0xC5,
   0x8C,0x6A,0x6B,0x6C,0x6D,0x6E,0x6F,0x70,0x71,0x72,0x97,0x87,0xCE,0x93,0xF1,0xFE,
   0xC8,0x7E,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7A,0xEF,0xC0,0xDA,0x5B,0xF2,0xAE,
   0xB5,0xB6,0xFD,0xB7,0xB8,0xB9,0xE6,0xBB,0xBC,0xBD,0x8D,0xD9,0xBF,0x5D,0xD8,0xC4,
   0x7B,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0xCB,0xCA,0xBE,0xE8,0xEC,0xED,
   0x7D,0x4A,0x4B,0x4C,0x4D,0x4E,0x4F,0x50,0x51,0x52,0xA1,0xAD,0xF5,0xF4,0xA3,0x8F,
   0x5C,0xE7,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5A,0xA0,0x85,0x8E,0xE9,0xE4,0xD1,
   0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0xB3,0xF7,0xF0,0xFA,0xA7,0xFF
};

int EZACIC04(picX *OUTPUT,
             binary98 *LENGTH)
{
   int i = 0;
   while ( i < bin982int(LENGTH))
   {
      OUTPUT[i] = Ebcdic2Ascii[OUTPUT[i]];
      i++;
   }
   return 0;
}

int EZACIC05(picX *OUTPUT,
             binary98 *LENGTH)
{
   int i = 0;
   while ( i < bin982int(LENGTH))
   {
      OUTPUT[i] = Ascii2Ebcdic[OUTPUT[i]];
      i++;
   }
   return 0;
}

#ifndef HP
static int PicX2char(char *Dst, picX *Src, int Size)
{
   int i;
   for (i = 0; i < Size; i++)
   {
      if (PicXisEbcdic)
      {
         Dst[i] = Ebcdic2Ascii[Src[i]];
      }
      else
      {
         Dst[i] = Src[i];
      }
   }
   Dst[i] = '\0';
}

static int NumInts(int CharMaskLen)
{
   return(((CharMaskLen + 32)/32)*4);
}
#endif

int EZACIC06(const char SocketCommand[16],
             binary98  *BITMASK,
             picX      *CHARMASK,
             binary98  *CHARMASKLEN,
             binary98s *RETCODE)
{
   int CharMaskLen = bin982int(CHARMASKLEN);
   /* Check document see what the actual limit should be */
   if (CharMaskLen > 255)
   {
      printf("ASSERTION: CharMaskLen %d > 255\n", CharMaskLen);
      exit(1);
   }

   if (!memcmp("BTOC", SocketCommand, 4))
   {
      int i = 0;
      int j;

      int BitMask = bin982int(&(BITMASK[i++]));

      for (j = CharMaskLen - 1; j >= 0; j--)
      {
         if (BitMask & 0x01)
         {
            CHARMASK[j] = '1';
         }
         else
         {
            CHARMASK[j] = '0';
         }
         BitMask = BitMask>>1;
         if ((j != 0) && ((j % 32) == 0))
         {
            BitMask = bin982int(&(BITMASK[i++]));
         }
      }
   }
   else if (!memcmp("CTOB", SocketCommand, 4))
   {
      int j;
      int i = 0;
      int BitMask = 0;
      /* j goes from n to 0, k goes from 0 to n */
      for (j = CharMaskLen - 1; j >= 0; j--)
      {
         int k = CharMaskLen - j - 1;
         /* printf("%d: b=%x b=%d j=%d k=%d c=%d\n",
                getpid(), BitMask, BitMask, j, k, CharMaskLen); */
         if (CHARMASK[j] == '0')
         {
            /* do nothing */
         }
         else if (CHARMASK[j] == '1')
         {
            BitMask |= 0x01<<(k%32);
         }
         else
         {
            int2bin98s(RETCODE, -1);
            return 0;
         }
         if ((j == 0) || (((k+1) % 32) == 0))
         {
            int2bin98(&(BITMASK[i]), BitMask);
            BitMask = 0;
            i++;
         }
      }
   }
   else
   {
      printf("%d: %4.4s not a command\n", getpid(), SocketCommand);
      int2bin98s(RETCODE, -1);
      return 0;
   }
   int2bin98s(RETCODE, 0);
   return 0;
}

int EZACIC08(pointer  *HOSTENT,
             binary94 *HOSTNAME_LENGTH,
             picX     *HOSTNAME,
             binary94 *HOSTALIAS_COUNT,
             binary94 *HOSTALIAS_SEQ,
             binary94 *HOSTALIAS_LENGTH, 
             picX     *HOSTALIAS_VALUE, 
             binary94 *HOSTADDR_TYPE, 
             binary94 *HOSTADDR_LENGTH, 
             binary94 *HOSTADDR_COUNT, 
             binary94 *HOSTADDR_SEQ, 
             binary98 *HOSTADDR_VALUE, 
             binary98s *RETCODE
             )
{
   int32_t i;
   char **List;
   char *Src;
   char *Dst;
   struct hostent *HostEnv = (struct hostent *)(*HOSTENT);
   if (HostEnv == NULL)
   {
      #ifdef LOG
      printf("%d: EZACIC08 - HostEnv is NULL\n", getpid());
      #endif
      int2bin98s(RETCODE, -1);
      return 0;
   }
   else
   {
      #ifdef LOG
      printf("%d: EZACIC08 - HostEnv is %p\n", getpid(), HostEnv);
      #endif
   }
   
   int32_t AliasSeq = bin942int(HOSTALIAS_SEQ);
   int32_t HostAddrSeq = bin942int(HOSTALIAS_SEQ);
   if (AliasSeq < 0 || HostAddrSeq < 0)
   {
      #ifdef LOG
      printf("%d: EZACIC08 - HOSTALIAS-SEQ(%d) or HOSTADDR-SEQ(%d) is invaild\n", getpid(), AliasSeq, HostAddrSeq);
      #endif
      int2bin98s(RETCODE, -1);
      return 0;
   }
   
   /* retrieve HOSTNAME */
   Src = HostEnv->h_name;
   Dst = HOSTNAME;
   while (1)
   {
      if (*Src == '\0')
      {
         break;
      }
      *Dst = *Src;
      Dst++;
      Src++;
   }
   int2bin94(HOSTNAME_LENGTH, Dst-HOSTNAME);
   
   /* retrieve HOSTALIAS information */
   List = HostEnv->h_aliases;
   i = 0;
   while (*List != NULL)
   {
      printf("%d: -->>>>>%p\n", getpid(), *List);
      if (i == AliasSeq)
      {
         Src = *List;
         Dst = HOSTALIAS_VALUE;
         while (1)
         {
            if (*Src == '\0')
            {
               break;
            }
            *Dst = *Src;
            Dst++;
            Src++;
         }
         int2bin94(HOSTALIAS_LENGTH, Dst-HOSTALIAS_VALUE);
         int2bin94(HOSTALIAS_SEQ, AliasSeq+1);
      }
      List++;
      i++;
   }
   int2bin94(HOSTALIAS_COUNT, i);
   
   /* retrieve the host address information*/
   int2bin94(HOSTADDR_TYPE, HostEnv->h_addrtype);
   int2bin94(HOSTADDR_LENGTH, HostEnv->h_length);
   List = HostEnv->h_addr_list;
   i = 0;
   
   while (*List != NULL)
   {
      if (i == HostAddrSeq)
      {
         switch (HostEnv->h_addrtype)
         {
            case AF_INET6:
            {
               #ifdef OPEN_EZASOKET_IPV6
               #error "ERROR: need to figure out how to set address for v6"
               #else
               #ifdef LOG
               printf("%d: EZACIC08 - Fail to convert ipv6 address\n", getpid());
               #endif
               int2bin98s(RETCODE, -1);
               #endif
               break;
            }
            case AF_INET:
            {
               int2bin98(HOSTADDR_VALUE, ntohl(*((int32_t *)(*List))));
               break;
            }
            default:
            {
               #ifdef LOG
               printf("%d: EZACIC08 - Unknown protocol family\n", getpid());
               #endif
               int2bin98s(RETCODE, -1);
               break;
            }
         }
         int2bin94(HOSTADDR_SEQ, HostAddrSeq+1);
      }
      List++;
      i++;
   }
   int2bin94(HOSTALIAS_COUNT, i);
   int2bin98s(RETCODE, 0);
   return 0;
}

