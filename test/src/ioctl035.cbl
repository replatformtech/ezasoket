       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           IOCTL035.

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
           01 IFADDRESS-DATA OCCURS 10 TIMES.
              05 IFADDRESS-NAME PIC X(16). 
              05 IFADDRESS-FAMILY PIC 9(4) COMPBINARY. 
              05 IFADDRESS-PORT PIC 9(4) COMPBINARY. 
              05 IFADDRESS-ADDRESS PIC 9(8) COMPBINARY. 
              05 IFADDRESS-RESERVED PIC X(8).
           01 RETSIZE PIC 9(8) COMPBINARY.
           01 IPV4ADDRESS PIC X(15).
           01 REVERT-FIELD PIC 9(8) COMPBINARY VALUES 1.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'IOCTL035' TO EZA-PROGRAM
           MOVE 5035       TO EZA-NAME-PORT

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
           MOVE X'C008A714' TO IOCTL-COMMAND-STR
           MOVE 3221792532 TO IOCTL-COMMAND
           MOVE 320 TO RETSIZE
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
               IOCTL-COMMAND
               RETSIZE
               IFADDRESS-DATA(1)
               EZA-ERRNO
               EZA-RETCODE
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: IOCTL returned with errorno ' EZA-ERRNO
           ELSE
      * Now we don't know how to get the return count of interface
              DISPLAY 'FAIL: IOCTL'
              CALL 'IPV42STR' USING IPV4ADDRESS IFADDRESS-ADDRESS(1) 
                                    REVERT-FIELD
              END-CALL
              DISPLAY 'Address1 of ' IFADDRESS-NAME(1) 'is: ' 
                     IPV4ADDRESS
              CALL 'IPV42STR' USING IPV4ADDRESS IFADDRESS-ADDRESS(2) 
                                    REVERT-FIELD
              END-CALL
              DISPLAY 'Address2 of ' IFADDRESS-NAME(2) 'is: ' 
                     IPV4ADDRESS
              CALL 'IPV42STR' USING IPV4ADDRESS IFADDRESS-ADDRESS(3) 
                                    REVERT-FIELD
              END-CALL
              DISPLAY 'Address3 of ' IFADDRESS-NAME(3) 'is: ' 
                     IPV4ADDRESS
              CALL 'IPV42STR' USING IPV4ADDRESS IFADDRESS-ADDRESS(4) 
                                    REVERT-FIELD
              END-CALL
              DISPLAY 'Address4 of ' IFADDRESS-NAME(4) 'is: ' 
                     IPV4ADDRESS
           END-IF
           DISPLAY 'COMPLETE: IOCTL test completed.'
           .

       IOCTL-EXIT.
           EXIT.




