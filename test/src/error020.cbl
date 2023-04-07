       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           ERROR020.

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

      * tests that 'The socket is already connected'
      * in connect that it returns an error.

           COPY EZADATA.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'ERROR020' TO EZA-PROGRAM
           MOVE 5020       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-CONNECT
           PERFORM EZA-CONNECT1

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY CONNECT.
           COPY ABEND.

       EZA-CONNECT1 SECTION.
       CONNECT1-START.
            MOVE 'CONNECT'  TO EZA-FUNCTION.
            MOVE 2          TO EZA-NAME-FAMILY
            MOVE LOW-VALUES TO EZA-NAME-IPADDRESS
 
            MOVE +0 TO EZA-ERRNO
            MOVE +0 TO EZA-RETCODE
            CALL 'EZASOKET'
                USING
                EZA-FUNCTION
                EZA-S
                EZA-NAME
                EZA-ERRNO
                EZA-RETCODE
            END-CALL
            IF EZA-RETCODE IS LESS THAN +0
              IF EZA-ERRNO-EISCONN
                 DISPLAY 'PASS: CONNECT returned EISCONN'
              ELSE
                 DISPLAY 'FAIL: CONNECT returned wrong error code '
                         EZA-ERRNO '.'
              END-IF
           ELSE
              DISPLAY 'FAIL: CONNECT did not fail.'
           END-IF
           DISPLAY 'COMPLETE: CONNECT test completed.'
            .
        CONNECT1-EXIT.
            EXIT.


