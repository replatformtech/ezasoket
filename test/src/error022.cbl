       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           ERROR022.

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

      * tests that 'The file descriptor is not associated 
      * with a socket.' in connect that it returns an error.

           COPY EZADATA.
           01  EZA-S-SAVE    PIC S9(04) COMP.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'ERROR022' TO EZA-PROGRAM
           MOVE 5678       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-CONNECT
           PERFORM EZA-CLOSE

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY CLOSE.
           COPY ABEND.

       EZA-CONNECT SECTION.
       CONNECT-START.
            MOVE 'CONNECT'  TO EZA-FUNCTION.
            MOVE 2          TO EZA-NAME-FAMILY
            MOVE LOW-VALUES TO EZA-NAME-IPADDRESS
 
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
            ADD EZA-S-SAVE TO EZA-S
            IF EZA-RETCODE IS LESS THAN +0
              IF EZA-ERRNO-ENOTSOCK
                 DISPLAY 'PASS: CONNECT returned ENOTSOCK'
              ELSE
                 DISPLAY 'FAIL: CONNECT returned wrong error code '
                         EZA-ERRNO '.'
              END-IF
           ELSE
              DISPLAY 'FAIL: CONNECT did not fail.'
           END-IF
           DISPLAY 'COMPLETE: CONNECT test completed.'
            .
        CONNECT-EXIT.
            EXIT.


