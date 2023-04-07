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

       EZA-SELECT-FDZERO-R SECTION.
       SELECT-FDZERO-R-START.
           MOVE ZEROS TO SEL-R-SND-STR

           MOVE 0 TO SEL-R-SND-MSK-ENTRY(1)
           MOVE 0 TO SEL-R-SND-MSK-ENTRY(2)
           .

       SELECT-FDZERO-R-EXIT.
           EXIT.

      *-------------------------------------------------

       EZA-SELECT-FDZERO-ALL SECTION.
       SELECT-FDZERO-ALL-START.
           MOVE ZEROS TO SEL-R-SND-STR
           MOVE ZEROS TO SEL-W-SND-STR
           MOVE ZEROS TO SEL-E-SND-STR
           MOVE ZEROS TO SEL-R-RTN-STR
           MOVE ZEROS TO SEL-W-RTN-STR
           MOVE ZEROS TO SEL-E-RTN-STR

           MOVE 0 TO SEL-R-SND-MSK-ENTRY(1)
           MOVE 0 TO SEL-W-SND-MSK-ENTRY(1)
           MOVE 0 TO SEL-E-SND-MSK-ENTRY(1)
           MOVE 0 TO SEL-R-RTN-MSK-ENTRY(1)
           MOVE 0 TO SEL-W-RTN-MSK-ENTRY(1)
           MOVE 0 TO SEL-E-RTN-MSK-ENTRY(1)
           MOVE 0 TO SEL-R-SND-MSK-ENTRY(2)
           MOVE 0 TO SEL-W-SND-MSK-ENTRY(2)
           MOVE 0 TO SEL-E-SND-MSK-ENTRY(2)
           MOVE 0 TO SEL-R-RTN-MSK-ENTRY(2)
           MOVE 0 TO SEL-W-RTN-MSK-ENTRY(2)
           MOVE 0 TO SEL-E-RTN-MSK-ENTRY(2)
           .

       SELECT-FDZERO-ALL-EXIT.
           EXIT.

      *-------------------------------------------------
       EZA-SELECT-FDADD-R SECTION.
       SELECT-FDADD-R-START.
           IF SEL-S > SEL-MAX-SOC
              GO TO AB-ABEND
           END-IF
           MOVE '1' TO SEL-R-SND-ARY-ENTRY(SEL-MAX-SOC - SEL-S + 1)

           MOVE 'CTOB'  TO SEL-TOKEN
           CALL 'EZACIC06' USING SEL-TOKEN
                                 SEL-R-SND-MSK
                                 SEL-R-SND-STR
                                 SEL-MAX-SOC
                                 SEL-RET-CODE
           END-CALL
           IF SEL-RET-CODE NOT EQUAL 0
              DISPLAY 'FAIL: EZACIC06 returned non-zero'
              GO TO AB-ABEND
           END-IF
           .

       SELECT-FDADD-R-EXIT.
           EXIT.

      *-------------------------------------------------
       EZA-SELECT SECTION.
       EZA-SELECT-START.
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE 'SELECT' TO EZA-FUNCTION
           MOVE -1 TO SEL-TIMEOUT-SECONDS
           MOVE  0 TO SEL-TIMEOUT-MICROSEC
           DISPLAY SEL-R-SND-MSK-ENTRY(1)
           DISPLAY SEL-R-SND-MSK-ENTRY(2)
           DISPLAY SEL-W-SND-MSK-ENTRY(1)
           DISPLAY SEL-W-SND-MSK-ENTRY(2)
           DISPLAY SEL-E-SND-MSK-ENTRY(1)
           DISPLAY SEL-E-SND-MSK-ENTRY(2)
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               SEL-MAX-SOC
               SEL-TIMEOUT
               SEL-R-SND-MSK 
               SEL-W-SND-MSK 
               SEL-E-SND-MSK 
               SEL-R-RTN-MSK 
               SEL-W-RTN-MSK 
               SEL-E-RTN-MSK 
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'SELECT failed with retcode ' EZA-RETCODE
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
               GO TO AB-ABEND
               EXIT
           END-IF

           MOVE 'BTOC'  TO SEL-TOKEN
           CALL 'EZACIC06' USING SEL-TOKEN
                                 SEL-R-RTN-MSK
                                 SEL-R-RTN-STR
                                 SEL-MAX-SOC
                                 SEL-RET-CODE
           END-CALL
           IF SEL-RET-CODE NOT EQUAL 0
              DISPLAY 'FAIL: EZACIC06 returned non-zero'
              GO TO AB-ABEND
           END-IF

           CALL 'EZACIC06' USING SEL-TOKEN
                                 SEL-W-RTN-MSK
                                 SEL-W-RTN-STR
                                 SEL-MAX-SOC
                                 SEL-RET-CODE
           END-CALL
           IF SEL-RET-CODE NOT EQUAL 0
              DISPLAY 'FAIL: EZACIC06 returned non-zero'
              GO TO AB-ABEND
           END-IF

           CALL 'EZACIC06' USING SEL-TOKEN
                                 SEL-E-RTN-MSK
                                 SEL-E-RTN-STR
                                 SEL-MAX-SOC
                                 SEL-RET-CODE
           END-CALL
           IF SEL-RET-CODE NOT EQUAL 0
              DISPLAY 'FAIL: EZACIC06 returned non-zero'
              GO TO AB-ABEND
           END-IF

           .


       EZA-SELECT-EXIT.
           EXIT.

