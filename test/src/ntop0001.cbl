       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           NTOP0001.

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
            01 PRESENTABLE-ADDRESS PIC X(45). 
            01 PRESENTABLE-ADDRESS-LEN PIC 9(4) COMPBINARY VALUES 45.
           
            01 EZA-NAME-IP PIC 9(8) COMPBINARY.
            01 NTOP-FAMILY PIC 9(8) COMPBINARY VALUES 2.

       LINKAGE SECTION.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'NTOP0001' TO EZA-PROGRAM

           PERFORM EZA-INITAPI
           PERFORM EZA-NTOP
           PERFORM EZA-TERMAPI
           GOBACK
           
           .

           COPY INITAPI.
           COPY TERMAPI.
           COPY ABEND.

       EZA-NTOP SECTION.
       NTOP-START.
           MOVE 'NTOP' TO EZA-FUNCTION
      *     MOVE X'7f000001' TO EZA-NAME-IPADDRESS
           MOVE 2130706433 TO EZA-NAME-IP
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               NTOP-FAMILY
               EZA-NAME-IP
               PRESENTABLE-ADDRESS
               PRESENTABLE-ADDRESS-LEN
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
                 DISPLAY 'FAIL: NTOP returned wrong error code '
                         EZA-ERRNO '.'
                 GO TO AB-ABEND
           ELSE
              IF PRESENTABLE-ADDRESS(1:PRESENTABLE-ADDRESS-LEN) = 
                 '127.0.0.1' THEN
                  DISPLAY 'PASS: NTOP RETURNED ADDRESS: ',
                        PRESENTABLE-ADDRESS(1:PRESENTABLE-ADDRESS-LEN)
              ELSE
                  DISPLAY 'FAIL: NTOP RETURNED ADDRESS: ',
                        PRESENTABLE-ADDRESS(1:PRESENTABLE-ADDRESS-LEN)
              END-IF
           END-IF
           DISPLAY 'COMPLETE'
           .

       NTOP-EXIT.
           EXIT.
