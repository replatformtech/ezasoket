       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           ERROR008.

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

      * tests the given address is already bound, then it returns
      * an error.

           COPY EZADATA.

           05  EZA-S1               PIC S9(04) COMPBINARY.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'ERROR008' TO EZA-PROGRAM
           MOVE 5678       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-SOCKET1
           PERFORM EZA-BIND1
           PERFORM EZA-CLOSE
           PERFORM EZA-CLOSE1

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY BIND.
           COPY CLOSE.
           COPY ABEND.

       EZA-SOCKET1 SECTION.
       SOCKET1-START.
           MOVE 'SOCKET' TO EZA-FUNCTION
           MOVE 2 TO EZA-AF
           MOVE 1 TO EZA-SOCTYPE
           MOVE 0 TO EZA-PROTO
           MOVE +0 TO EZA-ERRNO
           DISPLAY 'AF = ' EZA-AF
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-AF
               EZA-SOCTYPE
               EZA-PROTO
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'SOCKET failed with retcode ' EZA-RETCODE
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
               GO TO AB-0001
           END-IF
           MOVE EZA-RETCODE TO EZA-S1
           MOVE EZA-RETCODE TO EZA-S
           .

       SOCKET1-EXIT.
           EXIT.


       EZA-BIND1 SECTION.
       BIND1-START.
           MOVE 'BIND' TO EZA-FUNCTION.
           MOVE 2    TO EZA-NAME-FAMILY
           MOVE 5678 TO EZA-NAME-PORT
           MOVE LOW-VALUES TO EZA-NAME-IPADDRESS

           MOVE +0 TO EZA-ERRNO.
           MOVE +0 TO EZA-RETCODE.
           DISPLAY 'S BEFORE BIND ' EZA-S1
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S1
               EZA-NAME
               EZA-ERRNO
               EZA-RETCODE.
           IF EZA-RETCODE IS LESS THAN +0
              IF EZA-ERRNO-EADDRINUSE
                 DISPLAY 'PASS: BIND returned EINADDRINUSE'
              ELSE
                 DISPLAY 'FAIL: BIND returned wrong error code '
                         EZA-ERRNO '.'
              END-IF
           ELSE
              DISPLAY 'FAIL: BIND did not fail.'
           END-IF
           DISPLAY 'COMPLETE: BIND test completed.'
           .

       BIND1-EXIT.


       EZA-CLOSE1 SECTION.
       CLOSE1-START.
           MOVE 'CLOSE' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S1
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'CLOSE failed with retcode ' EZA-RETCODE
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
               GO TO AB-ABEND
           END-IF
           .
       CLOSE1-EXIT.
           EXIT.

