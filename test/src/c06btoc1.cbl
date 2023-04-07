       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           C06BTOC1.

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

       01  FILLER.
           05  CHAR-ARRAY.
               10  CHAR-ENTRY  PIC X(1) OCCURS 30 TIMES.
           05  CHAR-MASK REDEFINES CHAR-ARRAY PIC X(30).

       01  BIT-MASK.
           05  BIT-ENTRY PIC 9(8) COMP  OCCURS 1 TIMES.

       01  CHAR-MASK-LENGTH   PIC 9(8) COMPBINARY VALUE 30. 
       01  TOKEN              PIC X(16).
       01  RET-CODE           PIC S9(8) COMPBINARY.
       01  EZA-PROGRAM        PIC X(8).


       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'C06BTOC1' TO EZA-PROGRAM

           MOVE 'BTOC' TO TOKEN
           MOVE 33     TO BIT-ENTRY(1)

           CALL 'EZACIC06' USING TOKEN
                                 BIT-MASK
                                 CHAR-MASK
                                 CHAR-MASK-LENGTH
                                 RET-CODE
           END-CALL
           IF RET-CODE NOT EQUAL 0
              DISPLAY 'FAIL: EZACIC06 returned non-zero'
           ELSE
              IF CHAR-MASK EQUAL '000000000000000000000000100001'
                 DISPLAY 'PASS: '
              ELSE
                 DISPLAY 'FAIL: CHAR-MASK ' CHAR-MASK
              END-IF
           END-IF
           DISPLAY 'COMPLETE: '

           GOBACK.

