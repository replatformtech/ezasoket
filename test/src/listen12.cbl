       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           LISTEN12.

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
               10  EZA-NEW-NAME-FAMILY     PIC S9(04) COMPBINARY.
               10  EZA-NEW-NAME-PORT       PIC 9(04)  COMPBINARY.
               10  EZA-NEW-NAME-IPADDRESS  PIC 9(8)   COMPBINARY.
               10  FILLER              PIC X(08).

       
       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'LISTEN12' TO EZA-PROGRAM
           MOVE 5012       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-ACCEPT
           PERFORM EZA-GETSOCKNAME
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

       EZA-GETSOCKNAME SECTION.
       GETSOCKNAME-START.
           MOVE 'GETSOCKNAME' TO EZA-FUNCTION
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
              DISPLAY 'FAIL: GETSOCKNAME returned with errno: '
                      EZA-ERRNO
              GO TO AB-ABEND
           ELSE
              DISPLAY 'PASS: GETSOCKNAME RETURNED'
              DISPLAY 'SOCK PORT IS: ', EZA-NEW-NAME-PORT
              DISPLAY 'SOCK IP IS: ', 
                      EZA-NEW-NAME-IPADDRESS
           END-IF
           DISPLAY 'COMPLETE'
           .

       GETSOCKNAME-EXIT.
           EXIT.
