       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           ERROR010.

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

      * tests the socket is already bound, then it returns
      * an error.

           COPY EZADATA.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'ERROR010' TO EZA-PROGRAM
           MOVE 5678       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-BIND1
           PERFORM EZA-CLOSE

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY BIND.
           COPY CLOSE.
           COPY ABEND.

       EZA-BIND1 SECTION.
       BIND1-START.
           MOVE 'BIND' TO EZA-FUNCTION
           MOVE 2    TO EZA-NAME-FAMILY
           MOVE 5678 TO EZA-NAME-PORT
           MOVE LOW-VALUES TO EZA-NAME-IPADDRESS

           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           DISPLAY 'S BEFORE BIND ' EZA-S
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-NAME
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
              IF EZA-ERRNO-EINVAL
                 DISPLAY 'PASS: BIND returned EINVAL'
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
           EXIT.
