       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           LISTEN08.

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
           01 DATA-1 PIC X(5) VALUE SPACES.
           01 DATA-2 PIC X(5) VALUE SPACES.
           01 DATA-3 PIC X(5) VALUE SPACES.
           01 DATA-4 PIC X(8) VALUE SPACES.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'LISTEN08' TO EZA-PROGRAM
           MOVE 5008       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-ACCEPT
           PERFORM EZA-RECVMSG
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

       EZA-RECVMSG SECTION.
       RECVMSG-START.
       
           SET EZA-IOV-BUFFER(1) TO ADDRESS OF DATA-1
           SET EZA-IOV-BUFFER(2) TO ADDRESS OF DATA-2
           SET EZA-IOV-BUFFER(3) TO ADDRESS OF DATA-3
           SET EZA-IOV-BUFFER(4) TO ADDRESS OF DATA-4
           MOVE 5          TO EZA-IOV-BUFFER-LEN(1)
           MOVE 5          TO EZA-IOV-BUFFER-LEN(2)
           MOVE 5          TO EZA-IOV-BUFFER-LEN(3)
           MOVE 8          TO EZA-IOV-BUFFER-LEN(4)
           MOVE 4          TO EZA-IOVCNT
           
           SET EZA-MSG-IOV TO ADDRESS OF EZA-IOV
           SET EZA-MSG-IOVCNT TO ADDRESS OF EZA-IOVCNT
           
           SET EZA-MSG-NAME TO NULLS
           SET EZA-MSG-NAMELENGTH TO NULLS
           
           SET EZA-MSG-ACCRIGHTS TO NULLS
           SET EZA-MSG-ACCRLEN TO NULLS
           
           MOVE 'RECVMSG' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-MSG
               EZA-FLAGS
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           if EZA-RETCODE EQUAL 0
              DISPLAY 'CONNECTION CLOSED'
                       UPON CONSOLE
           else if EZA-RETCODE EQUAL -1
              DISPLAY 'RECVMSG failed with errno ' EZA-ERRNO
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
           else
              DISPLAY 'returned ' EZA-RETCODE ' : '
                     EZA-BUFFER(1:EZA-RETCODE)
                       UPON CONSOLE
              if DATA-1 EQUAL 'TEST ' AND DATA-2 EQUAL 'SEND ' AND
                  DATA-3 EQUAL 'FROM ' AND DATA-4 EQUAL 'SENDMSG8'
                 DISPLAY 'PASS: expected return from sendmsg8.cbl'
              else
                 DISPLAY 'Receive message is:' EZA-BUFFER(1:EZA-RETCODE)
                 DISPLAY 'FAIL: unexpected return from sendmsg8.cbl'
              end-if
              DISPLAY 'COMPLETE'
           end-if
           .

       RECVMSG-EXIT.
           EXIT.

