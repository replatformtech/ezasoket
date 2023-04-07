       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           GETNAME1.

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

            01 HOST PIC X(255) VALUES LOW-VALUES.
            01 SERVICE PIC X(32) VALUES LOW-VALUES.
            01 HOSTLEN PIC 9(8) COMPBINARY VALUES 255.
            01 SERVLEN PIC 9(8) COMPBINARY  VALUES 32.
            
            01 NAMELEN PIC 9(8) COMPBINARY.
            01 NAME-FLAGS PIC 9(8) COMPBINARY VALUE 0.
       PROCEDURE DIVISION.

            
       MAINLINE.
           
           MOVE 'GETNAME1' TO EZA-PROGRAM
           PERFORM EZA-INITAPI
           PERFORM EZA-GETNAMEINFO
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY INITAPI.
           COPY TERMAPI.
           COPY ABEND.
           
           
       EZA-GETNAMEINFO SECTION.
       GETNAMEINFO-START.
           MOVE 'GETNAMEINFO' TO EZA-FUNCTION
           MOVE 2  TO EZA-NAME-FAMILY
           MOVE 23 TO EZA-NAME-PORT
           MOVE X'7f000001' TO EZA-NAME-IPADDRESS 
           MOVE LOW-VALUES TO EZA-NAME-IPADDRESS
           
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-NAME
               NAMELEN
               HOST
               HOSTLEN
               SERVICE
               SERVLEN
               NAME-FLAGS
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: GETNAMEINFO returned wrong with errno ',
                      EZA-ERRNO
              GO TO AB-ABEND
           ELSE
              DISPLAY 'PASS: GETNAMEINFO RETURNED '
              DISPLAY 'HOST IS: ', HOST
              DISPLAY 'SERVICE IS: ', SERVICE
           END-IF
           DISPLAY 'COMPLETE'
           .

       GETNAMEINFO-EXIT.
           EXIT.
