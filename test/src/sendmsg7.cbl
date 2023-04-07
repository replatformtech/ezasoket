       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           SENDMSG7.

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
           01 DATA-1 PIC X(5) VALUE 'TEST '.
           01 DATA-2 PIC X(5) VALUE 'SEND '.
           01 DATA-3 PIC X(5) VALUE 'FROM '.
           01 DATA-4 PIC X(8) VALUE 'SENDMSG7'.
       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 5007       TO EZA-NAME-PORT
           MOVE 'SENDMSG7' TO EZA-PROGRAM

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-CONNECT
           PERFORM EZA-SENDMSG
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

           
       EZA-SENDMSG SECTION.
       SENDMSG-START.

                  
           MOVE 'SENDMSG' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           
           SET EZA-IOV-BUFFER(1) TO ADDRESS OF DATA-1
           SET EZA-IOV-BUFFER(2) TO ADDRESS OF DATA-2
           SET EZA-IOV-BUFFER(3) TO ADDRESS OF DATA-3
           SET EZA-IOV-BUFFER(4) TO ADDRESS OF DATA-4
           MOVE 5          TO EZA-IOV-BUFFER-LEN(1)
           MOVE 5          TO EZA-IOV-BUFFER-LEN(2)
           MOVE 5          TO EZA-IOV-BUFFER-LEN(3)
           MOVE 8          TO EZA-IOV-BUFFER-LEN(4)
           MOVE 4 TO EZA-IOVCNT
           
           SET EZA-MSG-IOV TO ADDRESS OF EZA-IOV
           SET EZA-MSG-IOVCNT TO ADDRESS OF EZA-IOVCNT
           
           SET EZA-MSG-NAME TO NULLS
           SET EZA-MSG-NAMELENGTH TO NULLS
           
           SET EZA-MSG-ACCRIGHTS TO NULLS
           SET EZA-MSG-ACCRLEN TO NULLS
           
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-FLAGS
               EZA-MSG
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'SENDMSG failed with retcode ' EZA-RETCODE
                       UPON CONSOLE
               GO TO AB-ABEND
           END-IF
           if EZA-RETCODE EQUAL 0
              DISPLAY 'SENDMSG did not write anything'
                       UPON CONSOLE
           else if EZA-RETCODE EQUAL -1
              DISPLAY 'SENDMSG failed with errno ' EZA-ERRNO
                       UPON CONSOLE
           else
              DISPLAY 'returned ' EZA-RETCODE ' : '
                     EZA-BUFFER(1:EZA-RETCODE)
                       UPON CONSOLE
           end-if
           .

       SENDMSG-EXIT.
           EXIT.

