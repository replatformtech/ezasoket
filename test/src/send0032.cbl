       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           SEND0032.

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

           MOVE 5032       TO EZA-NAME-PORT
           MOVE 'SEND0032' TO EZA-PROGRAM
           
           MOVE 'A' TO EZA-BUFFER
           MOVE 1 TO EZA-NBYTE

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-CONNECT
           PERFORM EZA-SEND
           PERFORM EZA-CLOSE
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY  INITAPI.
           COPY  SOCKET.
           COPY  CONNECT.
           COPY  CLOSE.
           COPY  TERMAPI.
           COPY  ABEND.
           
       EZA-SEND SECTION.
       SEND-START.
           MOVE 'SEND' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
      * send out of band data
           MOVE 1 TO EZA-FLAGS
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-FLAGS
               EZA-NBYTE
               EZA-BUFFER
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'SEND failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-ABEND
           END-IF
           if EZA-RETCODE EQUAL 0
              DISPLAY 'SEND did not write anything'
                       UPON CONSOLE
           else if EZA-RETCODE EQUAL -1
              DISPLAY 'SEND failed with errno ' EZA-ERRNO
                       UPON CONSOLE
           else
              DISPLAY 'returned ' EZA-RETCODE ' : '
                     EZA-BUFFER(1:EZA-RETCODE)
                       UPON CONSOLE
           end-if
           .

       SEND-EXIT.
           EXIT.

