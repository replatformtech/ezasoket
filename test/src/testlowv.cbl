       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           TESTLOWV.

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

            01 SRC PIC X(4). 
            01 DST    PIC X(8).
            01 SRCLEN PIC 9(8)  COMP VALUE 4.

       LINKAGE SECTION.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE LOW-VALUES TO SRC
           CALL 'PRINTHEX' USING DST SRC SRCLEN
           END-CALL
           IF DST =  '00000000' THEN
              DISPLAY 'PASS:MOVE LOW-VALUES MOVED ZEROS'
           ELSE
              DISPLAY 'FAIL:MOVE LOW-VALUES PRODUCED ' DST
           END-IF
           DISPLAY 'COMPLETE'
           .

