       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           IOCTL033.

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
           01 IFADDRESS-DATA.
              05 IFADDRESS-NAME PIC X(16). 
              05 IFADDRESS-FAMILY PIC 9(4) COMPBINARY. 
              05 IFADDRESS-PORT PIC 9(4) COMPBINARY. 
              05 IFADDRESS-ADDRESS PIC 9(8) COMPBINARY. 
              05 IFADDRESS-RESERVED PIC X(8).
              
           01 IPV4ADDRESS PIC X(15).
           01 REVERT-FIELD PIC 9(8) COMPBINARY VALUES 1.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'IOCTL033' TO EZA-PROGRAM
           MOVE 5033       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-IOCTL
           
           GOBACK
           .

           COPY INITAPI.
           COPY SOCKET.
           COPY ABEND.
           
       EZA-IOCTL SECTION.
       IOCTL-START.
           MOVE 'IOCTL' TO EZA-FUNCTION
      *     MOVE X'C020A70D' TO IOCTL-COMMAND-STR
           MOVE 3223365389 TO IOCTL-COMMAND
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE 'eth0' TO IFADDRESS-NAME
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               IOCTL-COMMAND
               IFADDRESS-DATA
               IFADDRESS-DATA
               EZA-ERRNO
               EZA-RETCODE
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: IOCTL returned with errorno ' EZA-ERRNO
           ELSE
              DISPLAY 'PASS: IOCTL'
              CALL 'IPV42STR' USING IPV4ADDRESS IFADDRESS-ADDRESS 
                                    REVERT-FIELD
              END-CALL
              DISPLAY 'Address is: ' IPV4ADDRESS
           END-IF
           DISPLAY 'COMPLETE: IOCTL test completed.'
           .

       IOCTL-EXIT.
           EXIT.




