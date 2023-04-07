       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           SEND0015.

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
           
         01 FIELDX. 
            05 FIELDX-CMD PIC X(10) value 'sleep 3'. 
            05 FIELDX-END PIC X(1)  value x'00'. 

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 5016       TO EZA-NAME-PORT
           MOVE 'SEND0016' TO EZA-PROGRAM
           MOVE 'TEST SEND FROM SEND0016' TO EZA-BUFFER
           MOVE 23         TO EZA-NBYTE

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-CONNECT
           PERFORM EZA-SEND
           PERFORM EZA-SLEEP
           DISPLAY 'start to recieve the response from listen16'
                   UPON CONSOLE
           PERFORM EZA-RECV
           PERFORM EZA-CLOSE
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY  INITAPI.
           COPY  SOCKET.
           COPY  CONNECT.
           COPY  SEND.
           COPY  CLOSE.
           COPY  TERMAPI.
           COPY  ABEND.

       EZA-RECV SECTION.
       RECV-START.
           MOVE 'RECV' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           MOVE 25 TO EZA-NBYTE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-FLAGS
               EZA-NBYTE
               EZA-BUFFER(1:25)
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           if EZA-RETCODE EQUAL 0
              DISPLAY 'FAILED READ BLOCK TEST: CONNECTION CLOSED'
                       UPON CONSOLE
           else if EZA-RETCODE EQUAL -1
              DISPLAY 'FAILED READ BLOCK TEST with errno ' EZA-ERRNO
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
           else if EZA-BUFFER(1:25) EQUAL 'TEST SEND FROM LISTEN0016'
              DISPLAY 'PASS READ BLOCK TEST' UPON CONSOLE
           else 
              if EZA-RETCODE > 0
                 DISPLAY 'FAILED READ BLOCK TEST returned: '
                      EZA-BUFFER(1:EZA-RETCODE) UPON CONSOLE
               else
                 DISPLAY 'FAILED READ BLOCK TEST returned '
                         EZA-RETCODE 'bytes'
               end-if
           end-if
           DISPLAY 'COMPLETE'
           .

       RECV-EXIT.
           EXIT.

       EZA-SLEEP SECTION.
       SLEEP-START.
           CALL "system" USING FIELDX
           .
       SLEEP-EXIT.
           EXIT.
