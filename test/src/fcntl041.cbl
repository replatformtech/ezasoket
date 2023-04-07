       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           FCNTL041.

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

      * test FCNTL for set

           COPY EZADATA.
           01 IOCTL-DATA.
              05 IOCTL-COMMAND PIC 9(8) COMPBINARY.
              05 IOCTL-COMMAND-STR REDEFINES IOCTL-COMMAND PIC X(4).
              05 IOCTL-BLOCK   PIC 9(8) COMPBINARY.
              
           01 FCNTL-COMMAND PIC 9(8) COMPBINARY.
           01 FCNTL-REQARG PIC 9(8) COMPBINARY.
       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'FCNTL041' TO EZA-PROGRAM
           MOVE 5041       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-FCNTL
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

           
       EZA-FCNTL SECTION.
       FCNTL-START.
           MOVE 'FCNTL' TO EZA-FUNCTION
           MOVE 4 TO FCNTL-COMMAND
           MOVE 4 TO FCNTL-REQARG
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               FCNTL-COMMAND
               FCNTL-REQARG
               EZA-ERRNO
               EZA-RETCODE
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FCNTL failed with retcode ' EZA-RETCODE
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
               GO TO AB-ABEND
               EXIT
           END-IF
           .

       FCNTL-EXIT.
           EXIT.




