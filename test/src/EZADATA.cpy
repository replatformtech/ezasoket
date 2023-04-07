      **
      **  This file is part of OpenEZA aka "Open Source EZASOKET".
      **
      **  OpenEZA is free software: you can redistribute it and/or
      **  modify it under the terms of the GNU General Public License
      **  as published by the Free Software Foundation, either
      **  version 3 of the License, or (at your option)
      **  any later version.
      **
      **  OpenEZA is distributed in the hope that it will be useful,
      **  but WITHOUT ANY WARRANTY; without even the implied warranty of
      **  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
      **  GNU General Public License for more details.
      **
      **  You should have received a copy of the
      **  GNU General Public License along with OpenEZA.
      **  If not, see <http://www.gnu.org/licenses/>.
      **

       01  EZA-CALL-DATA.
           05  EZA-FUNCTION            PIC X(16).
           05  EZA-AF                  PIC S9(09) COMPBINARY.
           05  EZA-BACKLOG             PIC S9(09) COMPBINARY.
           05  EZA-CLIENT.
               10  EZA-CLIENT-DOMAIN   PIC S9(09) COMPBINARY.
               10  EZA-CLIENT-NAME     PIC X(08).
               10  EZA-CLIENT-TASK     PIC X(08).
               10  FILLER              PIC X(20).
           05  EZA-COMMAND-X.
               10  EZA-COMMAND         PIC S9(09) COMPBINARY.
           05  EZA-FLAGS               PIC S9(09) COMPBINARY.
           05  EZA-HOSTADDR            PIC X(04).
           05  EZA-HOSTENT                        POINTER.
           05  EZA-HOW                 PIC S9(09) COMPBINARY.
           05  EZA-IDENT.
               10  EZA-IDENT-TCPNAME.
                   15  EZA-IDENT-TAG   PIC X(06).
                   15  EZA-IDENT-SYSID PIC X(02).
               10  EZA-IDENT-ADSNAME   PIC X(08).
           05  EZA-MAXSNO              PIC S9(09) COMPBINARY.
           05  EZA-MAXSOC              PIC S9(04) COMPBINARY.
           05  EZA-MAXSOC-SELECT       PIC S9(09) COMPBINARY.
           05  EZA-NAME.
               10  EZA-NAME-FAMILY     PIC S9(04) COMPBINARY.
               10  EZA-NAME-PORT       PIC 9(04)  COMPBINARY.
               10  EZA-NAME-IPADDRESS  PIC X(04).
               10  FILLER              PIC X(08).
           05  EZA-NAMELEN             PIC S9(08) COMPBINARY.
           05  EZA-NBYTE               PIC S9(09) COMPBINARY.
           05  EZA-OPTLEN              PIC S9(09) COMPBINARY.
           05  EZA-OPTNAME             PIC S9(09) COMPBINARY.
           05  EZA-OPTVALUE            PIC X(16).
           05  EZA-PROTO               PIC S9(09) COMPBINARY.
           05  EZA-RETCODE             PIC S9(09) COMPBINARY.
           05  EZA-S-X.
               10  EZA-S               PIC S9(04) COMPBINARY.
               10  EZA-S-ACCEPT        PIC S9(04) COMPBINARY.
           05  EZA-SOCRECV             PIC S9(04) COMPBINARY.
           05  EZA-SOCTYPE             PIC S9(09) COMPBINARY.
               88  EZA-SOCTYPE-STREAM                    VALUE +1.
               88  EZA-SOCTYPE-DATAGRAM                  VALUE +2.
           05  EZA-SUBTASK             PIC X(08).
           05  EZA-TIMEOUT.
               10  EZA-TIMEOUT-SECONDS PIC S9(09) COMPBINARY.
               10  EZA-TIMEOUT-MICROS  PIC S9(09) COMPBINARY.
           05  EZA-NAME-STR            PIC X(255).
           05  EZA-PROGRAM             PIC X(8).

           05  EZA-IOVCNT              PIC 9(8)   COMPBINARY.
           05  EZA-ERRNO               PIC S9(09) COMPBINARY.
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

       01  EZA-BUFFER  PIC X(1000).

       01  EZA-IOV.
           03  EZA-IOV-ENTRY          OCCURS 4 TIMES.
               05  EZA-IOV-BUFFER     USAGE IS POINTER.
               05  EZA-IOV-RESERVED   PIC X(4).
               05  EZA-IOV-BUFFER-LEN PIC 9(8) COMPBINARY.

       01  EZA-MSG.
           05 EZA-MSG-NAME       USAGE IS POINTER.
           05 EZA-MSG-NAMELENGTH USAGE IS POINTER.
           05 EZA-MSG-IOV        USAGE IS POINTER.
           05 EZA-MSG-IOVCNT     USAGE IS POINTER.
           05 EZA-MSG-ACCRIGHTS  USAGE IS POINTER.
           05 EZA-MSG-ACCRLEN    USAGE IS POINTER.   
            
           
       01  ABEND-INFORMATION.
           05  ABEND-CODE              PIC 9(04)      VALUE ZEROS.
