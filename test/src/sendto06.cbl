       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           SENDTO06.

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

           MOVE 5006       TO EZA-NAME-PORT
           MOVE 'SENDTO06' TO EZA-PROGRAM

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-CONNECT
           PERFORM EZA-SENDTO
           PERFORM EZA-CLOSE
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY CONNECT.
           COPY CLOSE.
           COPY TERMAPI.
           COPY ABEND.

           
       EZA-SENDTO SECTION.
       SENDTO-START.
           MOVE 'SENDTO' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE 'TEST SEND FROM SENDTO06' TO EZA-BUFFER
           MOVE 23         TO EZA-NBYTE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-FLAGS
               EZA-NBYTE
               EZA-BUFFER
               EZA-NAME
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'SENDTO failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-ABEND
           END-IF
           if EZA-RETCODE EQUAL 0
              DISPLAY 'SENDTO did not write anything'
                       UPON CONSOLE
           else if EZA-RETCODE EQUAL -1
              DISPLAY 'SENDTO failed with errno ' EZA-ERRNO
                       UPON CONSOLE
           else
              DISPLAY 'returned ' EZA-RETCODE ' : '
                     EZA-BUFFER(1:EZA-RETCODE)
                       UPON CONSOLE
           end-if
           .

       SENDTO-EXIT.
           EXIT.

