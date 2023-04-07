       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           LISTEN09.

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

      * implements Iterative, Connectionless Server Algorithm


           COPY EZADATA.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'LISTEN09' TO EZA-PROGRAM
           MOVE 5009       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-ACCEPT
           PERFORM EZA-RECVFROM
           PERFORM EZA-CLOSE
           PERFORM EZA-SHUTDOWN
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY BIND.
           COPY LISTEN.
           COPY ACCEPT.
           COPY CLOSE.
           COPY SHUTDOWN.
           COPY TERMAPI.
           COPY ABEND.

       EZA-RECVFROM SECTION.
       RECVFROM-START.
       
           MOVE 'RECVFROM' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           MOVE LENGTH OF EZA-BUFFER TO EZA-NBYTE
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
           if EZA-RETCODE EQUAL 0
              DISPLAY 'CONNECTION CLOSED'
                       UPON CONSOLE
           else if EZA-RETCODE EQUAL -1
              DISPLAY 'RECV failed with errno ' EZA-ERRNO
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
           else
              DISPLAY 'returned ' EZA-RETCODE ' : '
                     EZA-BUFFER(1:EZA-RETCODE)
                       UPON CONSOLE
              if EZA-BUFFER(1:EZA-RETCODE) EQUAL
                 'TEST SEND FROM SENDTO09'
                 DISPLAY 'PASS: expected return from SENDTO09.cbl'
              else
                 DISPLAY 'Receive message is:' EZA-BUFFER(1:EZA-RETCODE)
                 DISPLAY 'FAIL: unexpected return from SENDTO09.cbl'
              end-if
              DISPLAY 'COMPLETE'
           end-if
           .

       RECVFROM-EXIT.
           EXIT.

