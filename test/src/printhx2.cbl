       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           PRINTHX2.

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

         01 DST    PIC X(6).
         01 SRC    PIC X(3)  VALUE X'0102EE'.
         01 SRCLEN PIC 9(8)  COMP VALUE 3.
         01 REVERT-FIELD PIC 9(8) COMPBINARY VALUES 1.

       LINKAGE SECTION.

       PROCEDURE DIVISION.

       MAINLINE.

         
           CALL 'PRINTHEX' USING DST SRC SRCLEN REVERT-FIELD
           END-CALL

           IF DST EQUAL '0102EE'
              DISPLAY 'PASS: DST = ' DST
           ELSE
              DISPLAY 'FAIL: DST = ' DST
           END-IF
           
     
           DISPLAY 'COMPLETE:'

           GOBACK
           .


