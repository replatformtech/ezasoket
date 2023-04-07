       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           LISTEN11.

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
           01  EZA-NEW-NAME.
               10  EZA-NEW-NAME-FAMILY     PIC S9(04) COMP.
               10  EZA-NEW-NAME-PORT       PIC 9(04)  COMP.
               10  EZA-NEW-NAME-IPADDRESS  PIC 9(8)   COMPBINARY.
               10  FILLER                  PIC X(08).

       
       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'LISTEN11' TO EZA-PROGRAM
           MOVE 5011       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-ACCEPT
           PERFORM EZA-GETPEERNAME
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

       EZA-GETPEERNAME SECTION.
       GETPEERNAME-START.
           MOVE 'GETPEERNAME' TO EZA-FUNCTION
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
      *        EZA-NAME
               EZA-NEW-NAME
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: GETPEERNAME returned with errno: '
                      EZA-ERRNO
              GO TO AB-ABEND
           ELSE
              DISPLAY 'PASS: GETPEERNAME RETURNED'
              DISPLAY 'PEER CLIENT PORT IS: ', EZA-NEW-NAME-PORT
              DISPLAY 'PEER CLIENT IP IS: ', 
                      EZA-NEW-NAME-IPADDRESS
           END-IF
           DISPLAY 'COMPLETE'
           .

       GETPEERNAME-EXIT.
           EXIT.
