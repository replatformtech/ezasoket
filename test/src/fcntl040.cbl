       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           FCNTL040.

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

      * test fcntl for get.

           COPY EZADATA.
           01 IOCTL-DATA.
              05 IOCTL-COMMAND PIC 9(8) COMPBINARY.
              05 IOCTL-COMMAND-STR REDEFINES IOCTL-COMMAND PIC X(4).
              05 IOCTL-BLOCK   PIC 9(8) COMPBINARY.

           01 FCNTL-COMMAND PIC 9(8) COMPBINARY.
           01 FCNTL-REQARG PIC 9(8) COMPBINARY.
           01 FCNTL-RETCODE PIC 9(8) COMPBINARY.
           01 FCNTL-RETCODE-STR REDEFINES FCNTL-RETCODE PIC X(4).
       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'FCNTL040' TO EZA-PROGRAM
           MOVE 5040       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-IOCTL
           PERFORM EZA-FCNTL

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY BIND.
           COPY LISTEN.
           COPY ABEND.

       EZA-FCNTL SECTION.
       FCNTL-START.
           MOVE 'FCNTL' TO EZA-FUNCTION
           MOVE 3 TO FCNTL-COMMAND
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               FCNTL-COMMAND
               FCNTL-REQARG
               EZA-ERRNO
               FCNTL-RETCODE
           IF FCNTL-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: FCNTL failed with errorno ', EZA-ERRNO
           ELSE
              IF FCNTL-RETCODE-STR = X'00000004'
                 DISPLAY 'PASS: FCNTL returned NONBLOCKED'
              ELSE IF FCNTL-RETCODE-STR = X'00000000'
                 DISPLAY 'FAIL: FCNTL returned BLOCKED'
              ELSE
                 DISPLAY 'FAIL: FCNTL returned unknown data'
              END-IF
           END-IF
           DISPLAY 'COMPLETE: FCNTL test completed.'
           .

       FCNTL-EXIT.
           EXIT.

           
       EZA-IOCTL SECTION.
       IOCTL-START.
           MOVE 'IOCTL' TO EZA-FUNCTION
      * this is not correct for COMP-5
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




