These are random notes that I will eventually turn into a manual.

configure creates .mkf and .h
 - all defines go in .h.
 - do not use -D in makefile
 - to monitor how your config changes over time check config.mkf and config.h into a source code controller.

makefile does not rely on defaut rules.


running ./configure without options configures ezasoket to be as compatible as possible to the mainframe.

config options:
1) use comp or binary.
2) use ipv6
3) use mainframe compatible errors
4) use mainframe compatible family

if you want to add a feature to ezasoket that will break compatibility with the mainframe, then add an option to ./configure following comments in the configure script.

The ezasoket.so library does not require knowledge of the cobol compiler that it will link to, however the test suite does.  The configure script detects which cobol compiler is installed and compiles the test scripts accordingly.  if you have multiple compilers installed, then you need to pass the correct option to configure.


documentation should include:
1) how to choose the config options.
2) how to report a problem.


-------------------------
Compatibility issues:
1) For the numeric values passed to the EZASOKET functions some sample
   code and documents use COMP and some use BINARY.  BINARY will be the
   most compatible, but there is a lot of source that uses COMP.  This
   is a problem for two reasons: Byte order and truncation.

2) Most of the EZASOKET functions return an ERRNO.  The ERRNO returned
   could vary for the exact same error condition.

3) The ERRNO values used on different system have different numeric
   representations.

4) The AF_* values have different numeric representations on different
   systems.

5) 

-------------------------
Regarding the sections contained in test/src/*.cpy that wrap the
CALLS to EZASOKET:

EZA-S is returned from SOCKET
EZA-S is used as input to BIND, LISTEN, ACCEPT, CONNECT
EZA-S-ACCEPT are set by ACCEPT and CONNECT
EZA-S-ACCEPT are used by READ, RECV, SEND, WRITE, ...
EZA-S-ACCEPT is closed by CLOSE
EZA-S is closed by SHUTDOWN

CONNECT sets EZA-S-ACCEPT artificially as it is just a copy of EZA-S.

What this means is that if you do not do a successful ACCEPT or CONNECT,
then you should not do a CLOSE.   Maybe we should make CLOSE smarter.

-------------------------
Instructions:
1) Login here:
   Login Admin: https://portal.wush.net/
     and change your password.
     right now your user name and pw are the same.

2) svn co https://wush.net/svn/ezasoket

3) cd ezasoket/trunk

4) ./configure

5) make

6) cd test

7) ./compile

8) ./runtests

-------------------------
These are the error codes from HPUX:

#  define EAFNOSUPPORT          225     /*Address family not supported by
#define ENAMETOOLONG    248     /* File name too long           */
#define EINVAL          22      /* Invalid argument             */
#  define EPROTOTYPE            219     /* Protocol wrong type for socket */
#define EACCES          13      /* Permission denied            */
#  define EADDRINUSE            226     /* Address already in use */
#  define ENOTSOCK              216     /* Socket operation on non-socket */
#  define EADDRNOTAVAIL         227     /* Can't assign requested address */
#define EBADF           9       /* Bad file number              */
#  define EOPNOTSUPP            223     /* Operation not supported */
#  define ECONNREFUSED          239     /* Connection refused */
#  define EISCONN               234     /* Socket is already connected */
#  define ENETUNREACH           229     /* Network is unreachable */
#  define EPROTONOSUPPORT       221     /* Protocol not supported */
#define EAGAIN          11      /* No more processes


These are the error codes from Linux:

88  EZA-ERRNO-EAFNOSUPPORT      VALUE  97.
88  EZA-ERRNO-ENAMETOOLONG      VALUE  36.
88  EZA-ERRNO-EINVAL            VALUE  22.
88  EZA-ERRNO-EPROTOTYPE        VALUE  91.
88  EZA-ERRNO-EACCES            VALUE  13.
88  EZA-ERRNO-EADDRINUSE        VALUE  98.
88  EZA-ERRNO-ENOTSOCK          VALUE  88.
88  EZA-ERRNO-EADDRNOTAVAIL     VALUE  99.
88  EZA-ERRNO-EBADF             VALUE  9.
88  EZA-ERRNO-EOPNOTSUPP        VALUE  95.
88  EZA-ERRNO-ECONNREFUSED      VALUE 111.
88  EZA-ERRNO-EISCONN           VALUE 106.
88  EZA-ERRNO-ENETUNREACH       VALUE 101.
88  EZA-ERRNO-EPROTONOSUPPORT   VALUE 93.
88  EZA-ERRNO-EAGAIN            VALUE 11.
-------------------------
