       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           WRITE011.

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

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 5011       TO EZA-NAME-PORT
           MOVE 'WRITE011' TO EZA-PROGRAM

           PERFORM EZA-INITAPI.
           PERFORM EZA-SOCKET.
           PERFORM EZA-CONNECT.
           PERFORM EZA-GETPEERNAME.
           PERFORM EZA-CLOSE.
           PERFORM EZA-TERMAPI.
           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY CONNECT.
           COPY CLOSE.
           COPY TERMAPI.
           COPY ABEND.

       EZA-GETPEERNAME SECTION.
       GETPEERNAME-START.
           MOVE 'GETPEERNAME' TO EZA-FUNCTION
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-NAME
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: GETPEERNAME returned with errno: '
                      EZA-ERRNO
              GO TO AB-ABEND
           ELSE
              DISPLAY 'PASS: GETPEERNAME RETURNED'
              DISPLAY 'PEER CLIENT PORT IS: ', EZA-NAME-PORT
              DISPLAY 'PEER CLIENT IP IS: ', EZA-NAME-IPADDRESS
           END-IF
           DISPLAY 'COMPLETE'
           .

       GETPEERNAME-EXIT.
           EXIT.
