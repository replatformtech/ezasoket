       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           LISTEN13.

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
           01 OPTNAME PIC 9(8)  COMPBINARY. 
           01 OPTVAL  PIC 9(8)  COMPBINARY. 
           01 SO-TYPE-STR REDEFINES OPTVAL PIC X(4). 
           01 OPTLEN PIC 9(8) COMPBINARY.
           
           
  
       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'LISTEN13' TO EZA-PROGRAM
           MOVE 5013       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN
           PERFORM EZA-ACCEPT
           PERFORM EZA-GETSOCKOPT
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

       EZA-GETSOCKOPT SECTION.
       GETSOCKOPT-START.
           MOVE 'GETSOCKOPT' TO EZA-FUNCTION
      * try to get the opition SO_TYPE and expect the SOCK_STREAM     
           MOVE 4104 TO OPTNAME
           MOVE 4 TO OPTLEN
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               OPTNAME
               OPTVAL
               OPTLEN
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: GETSOCKOPT returned with errno: '
                      EZA-ERRNO
              GO TO AB-ABEND
           ELSE
      *        IF SO-TYPE-STR = X'00000001' THEN
               IF OPTVAL = 1 THEN
                 DISPLAY 'PASS: GETSOCKOPT RETURNED: ', OPTVAL
              ELSE
                 DISPLAY 'FAIL GETSOCKOPT RETURNED: ', OPTVAL
              END-IF
           END-IF
           DISPLAY 'COMPLETE'
           .

       GETSOCKOPT-EXIT.
           EXIT.
