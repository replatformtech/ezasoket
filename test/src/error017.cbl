       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           ERROR017.

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

      * tests that 'Socket is not listening for connections, or addrlen
      * is invalid' in accept that it returns an error.

           COPY EZADATA.
           01  EZA-S-SAVE    PIC S9(04) COMP.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'ERROR017' TO EZA-PROGRAM
           MOVE 5678       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-ACCEPT
           PERFORM EZA-CLOSE

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY BIND.
           COPY LISTEN.
           COPY CLOSE.
           COPY ABEND.

       EZA-ACCEPT SECTION.
       ACCEPT-START.
           MOVE 'ACCEPT' TO EZA-FUNCTION

           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE EZA-S TO EZA-S-SAVE
           MOVE 1 TO EZA-S

           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-NAME
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           MOVE EZA-S-SAVE TO EZA-S
           IF EZA-RETCODE IS LESS THAN +0
              IF EZA-ERRNO-ENOTSOCK
                 DISPLAY 'PASS: ACCEPT returned ENOTSOCK'
              ELSE
                 DISPLAY 'FAIL: ACCEPT returned wrong error code '
                         EZA-ERRNO '.'
              END-IF
           ELSE
              MOVE EZA-RETCODE TO EZA-S-ACCEPT
              DISPLAY 'FAIL: ACCEPT did not fail.'
           END-IF
           DISPLAY 'COMPLETE: ACCEPT test completed.'
           .

       ACCEPT-EXIT.
           EXIT.


