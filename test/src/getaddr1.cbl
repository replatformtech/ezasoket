       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           GETADDR1.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.

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

            COPY EZADATA.

            01 NODE PIC X(255) VALUES 'www.ustc.edu.cn'.
            01 SERVICE PIC X(32) VALUES 'TELNET'.

            01 NODELEN PIC 9(8) COMPBINARY.

            01 SERVLEN PIC 9(8) COMPBINARY.
            01 CANNLEN PIC 9(8) COMPBINARY.

            01 NULL-POINTER  USAGE IS POINTER.

            01 RES-ADDRINFO USAGE IS POINTER.


       LINKAGE SECTION.

            01  EZA-HINTS-ADDRINFO.
               03  EZA-HINTS-FLAGS           PIC 9(8) COMPBINARY.
               03  EZA-HINTS-AF              PIC 9(8) COMPBINARY.
               03  EZA-HINTS-SOCTYPE         PIC 9(8) COMPBINARY.
               03  EZA-HINTS-PROTO           PIC 9(8) COMPBINARY.
               03  FILLER                    PIC X(4).
               03  FILLER                    PIC X(4).
               03  FILLER                    PIC X(4).
               03  FILLER                    PIC X(4).

            01  EZA-RES-ADDRINFO.
               03  EZA-RES-FLAGS           PIC 9(8) COMPBINARY.
               03  EZA-RES-AF              PIC 9(8) COMPBINARY.
               03  EZA-RES-SOCTYPE         PIC 9(8) COMPBINARY.
               03  EZA-RES-PROTO           PIC 9(8) COMPBINARY.
               03  EZA-RES-NAMELEN         PIC 9(8) COMPBINARY.
               03  EZA-RES-CANONNAME       USAGE IS POINTER.
               03  EZA-RES-NAME            USAGE IS POINTER.
               03  EZA-RES-NEXT            USAGE IS POINTER.


       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'GETADDR1' TO EZA-PROGRAM

           PERFORM EZA-INITAPI
           PERFORM EZA-GETADDRINFO
           PERFORM EZA-FREEADDRINFO
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY INITAPI.
           COPY TERMAPI.
           COPY ABEND.


       EZA-GETADDRINFO SECTION.
       GETADDRINFO-START.
           MOVE 'GETADDRINFO' TO EZA-FUNCTION

           MOVE 15 TO NODELEN
           MOVE 6 TO SERVLEN

           SET NULL-POINTER TO NULL
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               NODE
               NODELEN
               SERVICE
               SERVLEN
               EZA-HINTS-ADDRINFO
               RES-ADDRINFO
               CANNLEN
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
                 DISPLAY 'FAIL: GETADDRINFO returned wrong error code '
                         EZA-ERRNO '.'
                 GO TO AB-ABEND
           ELSE
              SET ADDRESS OF EZA-RES-ADDRINFO TO RES-ADDRINFO
              DISPLAY 'Family is: ' EZA-RES-AF
              DISPLAY 'Socket type is: ' EZA-RES-SOCTYPE
              DISPLAY 'Protocol is: ' EZA-RES-PROTO
              DISPLAY 'PASS: GETADDRINFO RETURNED ADDRESSINFO ',
                       CANNLEN
           END-IF
           .

       GETADDRINFO-EXIT.
           EXIT.

       EZA-FREEADDRINFO SECTION.
       FREEADDRINFO-START.
           MOVE 'FREEADDRINFO' TO EZA-FUNCTION
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-RES-ADDRINFO
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
                 DISPLAY 'FAIL: FREEADDRINFO returned wrong error code '
                         EZA-ERRNO '.'
           ELSE
              DISPLAY 'PASS: FREEADDRINFO RETURNED ADDRESSINFO '
           END-IF
           DISPLAY 'COMPLETE'
           .

       FREEADDRINFO-EXIT.
           EXIT.
