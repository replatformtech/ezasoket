       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           ERROR014.

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

      * tests that 'The socket is not of a type that supports the
      * listen() operation' that it returns an error.

           COPY EZADATA.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'ERROR012' TO EZA-PROGRAM
           MOVE 5678       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-CLOSE

           GOBACK
           .

           COPY INITAPI.
           COPY BIND.
           COPY CLOSE.
           COPY ABEND.

       EZA-SOCKET SECTION.
       SOCKET-START.
           MOVE 'SOCKET' TO EZA-FUNCTION
           MOVE 2 TO EZA-AF
           MOVE 2 TO EZA-SOCTYPE
           MOVE 0 TO EZA-PROTO
           MOVE +0 TO EZA-ERRNO
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
               GO TO AB-ABEND
           END-IF
           MOVE EZA-RETCODE TO EZA-S
           .
       SOCKET-EXIT.
           EXIT.

       EZA-LISTEN SECTION.
       LISTEN-START.
           MOVE 'LISTEN' TO EZA-FUNCTION
           MOVE 12 TO EZA-BACKLOG
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-BACKLOG
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
              IF EZA-ERRNO-EOPNOTSUPP
                 DISPLAY 'PASS: LISTEN returned EOPNOTSUPP'
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

