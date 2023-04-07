       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           LISTEN01.

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

      * implements Iterative, Connectionless Server Algorithm


       01  ABEND-INFORMATION.
           03  CURRENT-FUNCTION        PIC X(20)      VALUE SPACES.
           03  CURRENT-ERROR           PIC 9(05)      VALUE ZEROES.
           03  ABEND-CODE              PIC 9(04)      VALUE ZEROS.
           03  ABEND-SPACE.
               05  ABEND-NUMBER        PIC S9(04)     VALUE ZEROS.
           03  PROGRAM-NAME            PIC X(8)       VALUE 'DUMPHOST'.

       01  EZA-CALL-DATA.
           05  EZA-FUNCTION            PIC X(16).
           05  EZA-AF                  PIC S9(09) COMP.
           05  EZA-BACKLOG             PIC S9(09) COMP.
           05  EZA-CLIENT.
               10  EZA-CLIENT-DOMAIN   PIC S9(09) COMP.
               10  EZA-CLIENT-NAME     PIC X(08).
               10  EZA-CLIENT-TASK     PIC X(08).
               10  FILLER              PIC X(20).
           05  EZA-COMMAND-X.
               10  EZA-COMMAND         PIC S9(09) COMP.
           05  EZA-ERRNO               PIC S9(09) COMP.
           05  EZA-FLAGS               PIC S9(09) COMP.
           05  EZA-HOSTADDR            PIC X(04).
           05  EZA-HOSTENT                        POINTER.
           05  EZA-HOW                 PIC S9(09) COMP.
           05  EZA-IDENT.
               10  EZA-IDENT-TCPNAME.
                   15  EZA-IDENT-TAG   PIC X(06).
                   15  EZA-IDENT-SYSID PIC X(02).
               10  EZA-IDENT-ADSNAME   PIC X(08).
           05  EZA-MAXSNO              PIC S9(09) COMP.
           05  EZA-MAXSOC              PIC S9(04) COMP.
           05  EZA-MAXSOC-SELECT       PIC S9(09) COMP.
           05  EZA-NAME.
               10  EZA-NAME-FAMILY     PIC S9(04) COMP.
               10  EZA-NAME-PORT       PIC 9(04)  COMP.
               10  EZA-NAME-IPADDRESS  PIC X(04).
               10  FILLER              PIC X(08).
           05  EZA-NAMELEN             PIC S9(08) COMP.
           05  EZA-NBYTE               PIC S9(09) COMP.
           05  EZA-OPTLEN              PIC S9(09) COMP.
           05  EZA-OPTNAME             PIC S9(09) COMP.
           05  EZA-OPTVALUE            PIC X(16).
           05  EZA-PROTO               PIC S9(09) COMP.
           05  EZA-RETCODE             PIC S9(09) COMP.
           05  EZA-S-X.
               10  EZA-S               PIC S9(04) COMP.
               10  EZA-S-ACCEPT        PIC S9(04) COMP.
           05  EZA-SOCRECV             PIC S9(04) COMP.
           05  EZA-SOCTYPE             PIC S9(09) COMP.
               88  EZA-SOCTYPE-STREAM                    VALUE +1.
               88  EZA-SOCTYPE-DATAGRAM                  VALUE +2.
           05  EZA-SUBTASK             PIC X(08).
           05  EZA-TIMEOUT.
               10  EZA-TIMEOUT-SECONDS PIC S9(09) COMP.
               10  EZA-TIMEOUT-MICROS  PIC S9(09) COMP.
           05  EZA-NAME-STR            PIC X(255).

       01  EZA-BUFFER  PIC X(1000).

       PROCEDURE DIVISION.

       MAINLINE.

           PERFORM EZA-INITAPI.
           PERFORM EZA-SOCKET.
           PERFORM EZA-BIND.
           PERFORM EZA-READ-BLOCK.
           PERFORM EZA-CLOSE.
           PERFORM EZA-TERMAPI.
           GOBACK.

       EZA-INITAPI SECTION.
       INITAPI-START.
           MOVE 'INITAPI' TO EZA-FUNCTION.
           MOVE +0 TO EZA-MAXSOC.
           MOVE SPACES TO EZA-IDENT.
           MOVE SPACES TO EZA-SUBTASK.
           MOVE +0 TO EZA-MAXSNO.
           MOVE +0 TO EZA-ERRNO.
           MOVE +0 TO EZA-RETCODE.
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-MAXSOC
               EZA-IDENT
               EZA-SUBTASK
               EZA-MAXSNO
               EZA-ERRNO
               EZA-RETCODE.
           MOVE EZA-FUNCTION TO CURRENT-FUNCTION.
           MOVE EZA-ERRNO TO CURRENT-ERROR.
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'INITAPI failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-0001.
       INITAPI-EXIT.
           EXIT.

       EZA-SOCKET SECTION.
       SOCKET-START.
           MOVE 'SOCKET' TO EZA-FUNCTION.
           MOVE 2 TO EZA-AF.
           MOVE 1 TO EZA-SOCTYPE.
           MOVE 0 TO EZA-PROTO.
           MOVE +0 TO EZA-ERRNO.
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-AF
               EZA-SOCTYPE
               EZA-PROTO
               EZA-ERRNO
               EZA-RETCODE.
           MOVE EZA-FUNCTION TO CURRENT-FUNCTION.
           MOVE EZA-ERRNO TO CURRENT-ERROR.
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'SOCKET failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-0001
           END-IF
           MOVE EZA-RETCODE TO EZA-S.
       SOCKET-EXIT.
           EXIT.


       EZA-BIND SECTION.
       BIND-START.
           MOVE 'BIND' TO EZA-FUNCTION.
           MOVE 2    TO EZA-NAME-FAMILY
           MOVE 5678 TO EZA-NAME-PORT
           MOVE LOW-VALUES TO EZA-NAME-IPADDRESS

           MOVE +0 TO EZA-ERRNO.
           MOVE +0 TO EZA-RETCODE.
           DISPLAY 'S BEFORE BIND ' EZA-S
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-NAME
               EZA-ERRNO
               EZA-RETCODE.
           DISPLAY 'S AFTER BIND ' EZA-S
           MOVE EZA-FUNCTION TO CURRENT-FUNCTION.
           MOVE EZA-ERRNO TO CURRENT-ERROR.
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'BIND failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-0001.
       BIND-EXIT.
           EXIT.

       EZA-CLOSE SECTION.
       CLOSE-START.
           MOVE 'CLOSE' TO EZA-FUNCTION.
           MOVE +0 TO EZA-ERRNO.
           MOVE +0 TO EZA-RETCODE.
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-ERRNO
               EZA-RETCODE.
           MOVE EZA-FUNCTION TO CURRENT-FUNCTION.
           MOVE EZA-ERRNO TO CURRENT-ERROR.
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'CLOSE failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-0001.
       CLOSE-EXIT.
           EXIT.

       EZA-READ-BLOCK SECTION.
       READ-BLOCK-START.
           MOVE 'READ' TO EZA-FUNCTION.
           MOVE +0 TO EZA-ERRNO.
           MOVE +0 TO EZA-RETCODE.
           MOVE LENGTH OF EZA-BUFFER TO EZA-NBYTE.
           DISPLAY 'S BEFORE READ ' EZA-S
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-NBYTE
               EZA-BUFFER
               EZA-ERRNO
               EZA-RETCODE.
           MOVE EZA-FUNCTION TO CURRENT-FUNCTION.
           MOVE EZA-ERRNO TO CURRENT-ERROR.
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'READ BLOCK failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-0001.
           if EZA-RETCODE EQUAL 0
              DISPLAY 'CONNECTION CLOSED'
                       UPON CONSOLE
           else if EZA-RETCODE EQUAL -1
              DISPLAY 'READ failed with errno ' EZA-ERRNO
                       UPON CONSOLE
           else
              DISPLAY 'returned ' EZA-RETCODE 
                      ' : ' EZA-BUFFER(1:EZA-RETCODE)
                       UPON CONSOLE
           end-if.

       READ-BLOCK-EXIT.
           EXIT.


       EZA-TERMAPI SECTION.
       TERMAPI-START.
           MOVE 'TERMAPI' TO EZA-FUNCTION.
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION.
           MOVE EZA-FUNCTION TO CURRENT-FUNCTION.
           MOVE EZA-ERRNO TO CURRENT-ERROR.
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'TERMAPI failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-0001.
       TERMAPI-EXIT.
           EXIT.

       UTILITY SECTION.
       AB-0001.
           MOVE 0001 TO ABEND-CODE.
           GO TO AB-ABEND.

       AB-ABEND.
           DISPLAY '*ABEND* ' PROGRAM-NAME UPON CONSOLE.
           DISPLAY 'PROGRAM ABEND=' ABEND-CODE UPON CONSOLE.
           DISPLAY 'FUNCTIONS=' CURRENT-FUNCTION UPON CONSOLE.
           DISPLAY 'ERROR=' CURRENT-ERROR UPON CONSOLE.
           MOVE SPACES TO ABEND-SPACE.
           ADD +1 TO ABEND-NUMBER.
       AB-EXIT.
           EXIT.
