       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           PTON0001.

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
            01 PRESENTABLE-ADDRESS-LEN PIC 9(4) COMPBINARY VALUES 9.
            
            01 PTON-FAMILY PIC 9(8) COMPBINARY VALUES 2.
            
            01 IPADDRESS PIC 9(8) COMPBINARY.
            01 UNIIPADDRESS PIC 9(8) COMP.
            
            01 DST    PIC X(8).
            01 SRCLEN PIC 9(8)  COMP VALUE 4.

       LINKAGE SECTION.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'PTON0001' TO EZA-PROGRAM

           PERFORM EZA-INITAPI
           PERFORM EZA-PTON
           PERFORM EZA-TERMAPI
           GOBACK
           
           .

           COPY INITAPI.
           COPY TERMAPI.
           COPY ABEND.

       EZA-PTON SECTION.
       PTON-START.
           MOVE 'PTON' TO EZA-FUNCTION
           MOVE '127.0.0.1' TO PRESENTABLE-ADDRESS
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               PTON-FAMILY
               PRESENTABLE-ADDRESS
               PRESENTABLE-ADDRESS-LEN
               IPADDRESS
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
                 DISPLAY 'FAIL: PTON returned wrong error code '
                         EZA-ERRNO '.'
                 GO TO AB-ABEND
           ELSE
              MOVE IPADDRESS TO UNIIPADDRESS
              CALL 'PRINTHEX' USING DST UNIIPADDRESS SRCLEN
              END-CALL
              IF IPADDRESS =  2130706433 THEN
                  DISPLAY 'PASS:PTON RETURNED ADDRESS: ',
                        DST
              ELSE
                  DISPLAY 'FAIL: PTON RETURNED ADDRESS: ',
                        DST
              END-IF
           END-IF
           DISPLAY 'COMPLETE'
           .

       PTON-EXIT.
           EXIT.
