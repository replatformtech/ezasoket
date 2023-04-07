       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           IOCTL032.

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
           COPY SELDATA.
           01 IOCTL-DATA.
              05 IOCTL-COMMAND PIC 9(8) COMPBINARY.
              05 IOCTL-COMMAND-STR REDEFINES IOCTL-COMMAND PIC X(4).
              05 IOCTL-ONOOB   PIC 9(8) COMPBINARY.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'IOCTL032' TO EZA-PROGRAM
           MOVE 5032       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-ACCEPT
           PERFORM EZA-SELECT-FDZERO-ALL
           PERFORM EZA-SLEEP
           PERFORM EZA-IOCTL
           PERFORM EZA-CLOSE
           PERFORM EZA-SHUTDOWN

           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY BIND.
           COPY LISTEN.
           COPY ACCEPT.
           COPY SELECT.
           COPY CLOSE.
           COPY SHUTDOWN.
           COPY ABEND.

       EZA-SLEEP SECTION.
       SLEEP-START.
           MOVE 'SELECT' TO EZA-FUNCTION
           MOVE  1 TO SEL-TIMEOUT-SECONDS
           MOVE  0 TO SEL-TIMEOUT-MICROSEC
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               SEL-MAX-SOC
               SEL-TIMEOUT
               SEL-R-SND-MSK 
               SEL-W-SND-MSK 
               SEL-E-SND-MSK 
               SEL-R-RTN-MSK 
               SEL-W-RTN-MSK 
               SEL-E-RTN-MSK 
               EZA-ERRNO
               EZA-RETCODE
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'SELECT failed with retcode ' EZA-RETCODE
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
               GO TO AB-ABEND
               EXIT
           END-IF
           .

       SLEEP-EXIT.
           EXIT.

           
       EZA-IOCTL SECTION.
       IOCTL-START.
           MOVE 'IOCTL' TO EZA-FUNCTION
      *     MOVE X'4004A707' TO IOCTL-COMMAND-STR
           MOVE 1074046727 TO IOCTL-COMMAND
           MOVE 1 TO IOCTL-ONOOB
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               IOCTL-COMMAND
               IOCTL-ONOOB
               IOCTL-ONOOB
               EZA-ERRNO
               EZA-RETCODE
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: IOCTL returned with errorno ' EZA-ERRNO
           ELSE
              IF IOCTL-ONOOB = 0
                 DISPLAY 'PASS: IOCTL returned ' IOCTL-ONOOB
              ELSE
                 DISPLAY 'FAIL: IOCTL returned ' IOCTL-ONOOB
              END-IF
              
           END-IF
           DISPLAY 'COMPLETE: IOCTL test completed.'
           .

       IOCTL-EXIT.
           EXIT.

           
           



