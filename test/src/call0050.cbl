       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           CALL0050.

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

      * call program for takesocket and givesocket
           COPY EZADATA.
           COPY SELDATA.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 5050       TO EZA-NAME-PORT
           MOVE 'CALL0050' TO EZA-PROGRAM
           
           PERFORM EZA-INITAPI.
           PERFORM EZA-SOCKET.
           PERFORM EZA-CONNECT.
           MOVE 'take0050' TO EZA-BUFFER
           MOVE 8 TO EZA-NBYTE
           PERFORM EZA-SEND.
           PERFORM EZA-SLEEP.
           MOVE 'TEST SEND FROM CALL0050' TO EZA-BUFFER
           MOVE 23 TO EZA-NBYTE
           PERFORM EZA-SEND.
           PERFORM EZA-CLOSE.
           PERFORM EZA-TERMAPI.
           GOBACK
           .
           
           COPY  INITAPI.
           COPY  SOCKET.
           COPY  CONNECT.
           COPY  SEND.
           COPY  CLOSE.
           COPY  TERMAPI.
           COPY  ABEND.
           COPY SELECT.
           
       EZA-SLEEP SECTION.
       SLEEP-START.
           PERFORM EZA-SELECT-FDZERO-ALL
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
