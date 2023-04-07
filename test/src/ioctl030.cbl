       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           IOCTL030.

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

      * test command FIONBIO

           COPY EZADATA.
           01 IOCTL-DATA.
              05 IOCTL-COMMAND PIC 9(8) COMPBINARY.
              05 IOCTL-COMMAND-STR REDEFINES IOCTL-COMMAND PIC X(4).
              05 IOCTL-BLOCK   PIC 9(8) COMPBINARY.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'IOCTL030' TO EZA-PROGRAM
           MOVE 5030       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-IOCTL
           PERFORM EZA-ACCEPT

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY BIND.
           COPY LISTEN.
           COPY ABEND.

       EZA-ACCEPT SECTION.
       ACCEPT-START.
           MOVE 'ACCEPT' TO EZA-FUNCTION
        
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               EZA-NAME
               EZA-ERRNO
               EZA-RETCODE
           IF EZA-RETCODE IS LESS THAN +0
              IF EZA-ERRNO-EAGAIN
                 DISPLAY 'PASS: ACCEPT returned EAGAIN'
              ELSE
                 DISPLAY 'FAIL: ACCEPT returned wrong error code '
                         EZA-ERRNO '.'
              END-IF
           ELSE
              DISPLAY 'FAIL: ACCEPT did not fail.'
           END-IF
           DISPLAY 'COMPLETE: ACCEPT test completed.'
           .

       ACCEPT-EXIT.
           EXIT.

           
       EZA-IOCTL SECTION.
       IOCTL-START.
           MOVE 'IOCTL' TO EZA-FUNCTION
      *    MOVE X'8004A77E' TO IOCTL-COMMAND-STR
           MOVE 2147788670 TO IOCTL-COMMAND
           MOVE 1 TO IOCTL-BLOCK
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               IOCTL-COMMAND
               IOCTL-BLOCK
               IOCTL-BLOCK
               EZA-ERRNO
               EZA-RETCODE
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'IOCTL failed with retcode ' EZA-RETCODE
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
               GO TO AB-ABEND
               EXIT
           END-IF
           .

       IOCTL-EXIT.
           EXIT.




