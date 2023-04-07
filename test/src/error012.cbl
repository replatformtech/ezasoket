       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           ERROR012.

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

      * tests that 'The argument sockfd is not a valid descriptor'
      * that it returns an error.

           COPY EZADATA.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'ERROR012' TO EZA-PROGRAM
           MOVE 5678       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY BIND.
           COPY ABEND.

       EZA-LISTEN SECTION.
       LISTEN-START.
           MOVE 'LISTEN' TO EZA-FUNCTION
           MOVE 12 TO EZA-BACKLOG
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           ADD 1 TO EZA-S
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-BACKLOG
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           ADD -1 TO EZA-S
           IF EZA-RETCODE IS LESS THAN +0
              IF EZA-ERRNO-EBADF OR EZA-ERRNO-ENOTSOCK
                 DISPLAY 'PASS: LISTEN returned EBADF'
              ELSE
                 DISPLAY 'FAIL: LISTEN returned wrong error code '
                         EZA-ERRNO '.'
              END-IF
           ELSE
              DISPLAY 'FAIL: LISTEN did not fail.'
           END-IF
           DISPLAY 'COMPLETE: LISTEN test completed.'
           .
       LISTEN-EXIT.
           EXIT.

           .

