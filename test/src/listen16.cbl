       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           LISTEN16.

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

      * implements Concurrency Using a Single Process

           COPY EZADATA.
           COPY SELDATA.
         01 BYTES-READ PIC S9(8) COMP VALUE 0.
         01 BUF-INDEX  PIC S9(8) COMP.
         01 RECV-RET PIC X(1).
            88 RECV-SUCCESS VALUE 'Y'.
            88 RECV-FAIL    VALUE 'N'.
         01 FIELDX. 
            05 FIELDX-CMD PIC X(10) value 'sleep 5'. 
            05 FIELDX-END PIC X(1)  value x'00'. 
            
       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'LISTEN16' TO EZA-PROGRAM
           MOVE 5016       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN

           PERFORM EZA-ACCEPT
           PERFORM EZA-RECV
           if RECV-SUCCESS
              DISPLAY "start to send back message to send0016"
              MOVE 'TEST SEND FROM LISTEN0016' TO EZA-BUFFER
              MOVE 25 TO EZA-NBYTE
              PERFORM EZA-SEND
      * this line can be ignored
              PERFORM EZA-SLEEP
           else
              DISPLAY "fail to recieve the message from send0016"
           end-if
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
           COPY SEND.
           COPY CLOSE.
           COPY SHUTDOWN.
           COPY TERMAPI.
           COPY SELECT.
           COPY ABEND.

       EZA-RECV SECTION.
       RECV-START.
           SET RECV-FAIL TO TRUE
           MOVE 'RECV' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           MOVE 4 TO EZA-NBYTE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-FLAGS
               EZA-NBYTE
               EZA-BUFFER(1:23)
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
              SET RECV-SUCCESS TO TRUE
           end-if
           .

       RECV-EXIT.
           EXIT.
           
       EZA-SLEEP SECTION.
       SLEEP-START.
           CALL "system" USING FIELDX
           .
       SLEEP-EXIT.
           EXIT.
           