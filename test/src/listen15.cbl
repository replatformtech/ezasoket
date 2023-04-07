       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           LISTEN15.

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

      * implements Concurrency Using a Single Process

           COPY EZADATA.
           COPY SELDATA.
         01 ECBLIST-PTR USAGE IS POINTER VALUES NULL.
         01 BYTES-READ PIC S9(8) COMP VALUE 0.
         01 BUF-INDEX  PIC S9(8) COMP.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'LISTEN15' TO EZA-PROGRAM
           MOVE 5015       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-SOCKET
           PERFORM EZA-BIND
           PERFORM EZA-LISTEN

           PERFORM EZA-SELECT-FDZERO-ALL
           MOVE EZA-S TO SEL-S
           MOVE 0 TO EZA-S-ACCEPT
           PERFORM EZA-SELECT-FDADD-R

           PERFORM UNTIL BYTES-READ >= 23
              PERFORM EZA-SELECTEX
              DISPLAY SEL-R-RTN-STR
              IF EZA-S NOT EQUAL 0 AND
                 SEL-R-RTN-ARY-ENTRY(SEL-MAX-SOC - EZA-S + 1)
                 EQUAL '1'
                 PERFORM EZA-ACCEPT
                 PERFORM EZA-SELECT-FDZERO-R
                 MOVE EZA-S-ACCEPT TO SEL-S
                 PERFORM EZA-SELECT-FDADD-R
              END-IF
              IF EZA-S-ACCEPT NOT EQUAL 0 AND
                 SEL-R-RTN-ARY-ENTRY(SEL-MAX-SOC - EZA-S-ACCEPT + 1)
                 EQUAL '1'
                 PERFORM EZA-RECV
                 PERFORM EZA-SELECT-FDZERO-R
                 MOVE EZA-S-ACCEPT TO SEL-S
                 PERFORM EZA-SELECT-FDADD-R
              END-IF
           END-PERFORM

           if EZA-BUFFER(1:BYTES-READ) EQUAL
                 'TEST SEND FROM SEND0015'
              DISPLAY 'PASS: expected return from send0015.cbl'
           else
              DISPLAY 'FAIL: unexpected return from send0015.cbl'
              DISPLAY BYTES-READ ':' EZA-BUFFER(1:BYTES-READ)
           end-if
           DISPLAY 'COMPLETE'
           
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
           COPY SELECT.
           COPY ABEND.

       EZA-RECV SECTION.
       RECV-START.
           MOVE 'RECV' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           MOVE 4 TO EZA-NBYTE
           ADD 1 TO BYTES-READ GIVING BUF-INDEX
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-FLAGS
               EZA-NBYTE
               EZA-BUFFER(BUF-INDEX:4)
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           if EZA-RETCODE EQUAL 0
              DISPLAY 'CONNECTION CLOSED'
                       UPON CONSOLE
           else if EZA-RETCODE EQUAL -1
              DISPLAY 'RECV failed with errno ' EZA-ERRNO
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
           else
              DISPLAY 'returned ' EZA-RETCODE ' : '
                     EZA-BUFFER(BUF-INDEX:EZA-RETCODE)
                       UPON CONSOLE
              ADD  EZA-RETCODE TO BYTES-READ
           end-if
           .

       RECV-EXIT.
           EXIT.
           
       EZA-SELECTEX SECTION.
       EZA-SELECTEX-START.
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE 'SELECTEX' TO EZA-FUNCTION
           MOVE -1 TO SEL-TIMEOUT-SECONDS
           MOVE  0 TO SEL-TIMEOUT-MICROSEC
           DISPLAY SEL-R-SND-MSK-ENTRY(1)
           DISPLAY SEL-R-SND-MSK-ENTRY(2)
           DISPLAY SEL-W-SND-MSK-ENTRY(1)
           DISPLAY SEL-W-SND-MSK-ENTRY(2)
           DISPLAY SEL-E-SND-MSK-ENTRY(1)
           DISPLAY SEL-E-SND-MSK-ENTRY(2)
           
      *     SET ECBLIST-PTR TO ADDRESS OF EZA-ERRNO
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
               BY VALUE ECBLIST-PTR
               BY REFERENCE EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'SELECTEX failed with retcode ' EZA-RETCODE
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


       EZA-SELECTEX-EXIT.
           EXIT.


