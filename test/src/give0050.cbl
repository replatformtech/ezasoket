       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           GIVE0050.

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

      * test for give socket
           COPY EZADATA.
           COPY SELDATA.
           01 EZA-CLIENTID. 
              05 EZA-CLIENTID-DOMAIN PIC 9(8) COMPBINARY. 
              05 EZA-CLIENTID-NAME PIC X(8). 
              05 EZA-CLIENTID-TASK PIC X(8). 
              05 EZA-CLIENTID-RESERVED PIC X(20).
           01 EZA-CLIENTID-TASK-STR PIC X(9).

           01 WS-STOP PIC X(01) VALUE SPACE.
           01 EZA-CALLPROGRAM PIC X(08).
           01 EZA-CALLPRGPATH PIC X(100).
           01 EZA-SAVE PIC 9(4) COMPBINARY.
           
           01 NULL-POINTER USAGE IS POINTER.
           
           01 PID PIC 9(8) COMPBINARY.
           01 OFFSET PIC 9 COMP.

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'GIVE0050' TO EZA-PROGRAM
           MOVE 5050       TO EZA-NAME-PORT
           PERFORM EZA-INITAPI.
           PERFORM EZA-GETCLIENTID.
           PERFORM EZA-SOCKET.
           PERFORM EZA-BIND.
           PERFORM EZA-LISTEN.
           PERFORM EZA-ACCEPTLOOP.
           PERFORM EZA-SHUTDOWN.
           PERFORM EZA-TERMAPI.
           GOBACK
           .
           
           COPY INITAPI.
           COPY SOCKET.
           COPY ABEND.
           COPY BIND.
           COPY LISTEN.
           COPY SELECT.
           COPY ACCEPT.
           COPY CLOSE.
           COPY TERMAPI.
           COPY SHUTDOWN.
       
           EZA-ACCEPTLOOP.
              IF WS-STOP NOT EQUAL 'Y'
                 PERFORM EZA-SELECT-FDZERO-ALL
                 MOVE EZA-S TO SEL-S
                 PERFORM EZA-SELECT-FDADD-R
                 PERFORM EZA-SELECT
                 
                 IF EZA-S NOT EQUAL 0 AND
                    SEL-R-RTN-ARY-ENTRY(SEL-MAX-SOC - EZA-S + 1)
                    EQUAL '1'
                    PERFORM EZA-ACCEPT
                    DISPLAY "ACCEPT SOCKET IS: ", EZA-S-ACCEPT
                    PERFORM EZA-RECV
                    PERFORM EZA-GIVESOCKET
                    PERFORM EZA-SPWANCHILD
                    PERFORM EZA-RECVTMP
                    PERFORM EZA-WAITFORTAKESOCKET
                    PERFORM EZA-CLOSE
                 END-IF
                 GO TO EZA-ACCEPTLOOP
              ELSE
                 PERFORM EZA-CLOSE
              END-IF
              GOBACK
              .
              
       EZA-GETCLIENTID SECTION.
       GETCLIENTID-START.
           MOVE 'GETCLIENTID'  TO EZA-FUNCTION.
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-CLIENTID
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0            
              DISPLAY 'FAIL: getclientid return with errorno: ',
                      EZA-ERRNO
              GO TO AB-ABEND
           END-IF
           .

       GETCLIENTID-EXIT.
           EXIT.
           
       EZA-RECV SECTION.
       RECV-START.
           MOVE 'RECV' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           MOVE 8 TO EZA-NBYTE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-FLAGS
               EZA-NBYTE
               EZA-CALLPROGRAM(1:8)
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           if EZA-RETCODE IS LESS THAN +0  
              DISPLAY 'FAIL: RECV return with errorno: ',
                      EZA-ERRNO
              GO TO AB-ABEND
           else
              IF EZA-CALLPROGRAM(1:4) = 'STOP'
                 MOVE 'Y' TO WS-STOP
              ELSE
                 DISPLAY "the call program is: ", EZA-CALLPROGRAM
              END-IF
           end-if
           .

       RECV-EXIT.
           EXIT.
           
       EZA-SELECT-FDADD-E SECTION.
       SELECT-FDADD-E-START.
           IF SEL-S > SEL-MAX-SOC
              GO TO AB-ABEND
           END-IF
           MOVE '1' TO SEL-E-SND-ARY-ENTRY(SEL-MAX-SOC - SEL-S + 1)

           MOVE 'CTOB'  TO SEL-TOKEN
           CALL 'EZACIC06' USING SEL-TOKEN
                                 SEL-E-SND-MSK
                                 SEL-E-SND-STR
                                 SEL-MAX-SOC
                                 SEL-RET-CODE
           END-CALL
           IF SEL-RET-CODE NOT EQUAL 0
              DISPLAY 'FAIL: EZACIC06 returned non-zero'
              GO TO AB-ABEND
           END-IF
           .

       SELECT-FDADD-E-EXIT.
           EXIT.
           
       EZA-WAITFORTAKESOCKET SECTION.
       EZA-WAITFORTAKESOCKET-START.
           PERFORM EZA-SELECT-FDZERO-ALL
           MOVE EZA-S-ACCEPT TO SEL-S
           PERFORM EZA-SELECT-FDADD-E
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE 'SELECT' TO EZA-FUNCTION
           MOVE -1 TO SEL-TIMEOUT-SECONDS
           MOVE  30 TO SEL-TIMEOUT-MICROSEC
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


       EZA-WAITFORTAKESOCKET-EXIT.
           EXIT.
       
       EZA-GIVESOCKET SECTION.
       GIVESOCKET-START.
           MOVE 'GIVESOCKET' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           MOVE 8 TO EZA-NBYTE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-CLIENTID
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           if EZA-RETCODE IS LESS THAN +0  
              DISPLAY 'FAIL: GIVESOCKET return with errorno: ',
                      EZA-ERRNO
              GO TO AB-ABEND
           end-if
           .

       GIVESOCKET-EXIT.
           EXIT.

       EZA-SPWANCHILD SECTION.
       SPWANCHILD-START.
           move LOW-VALUES to EZA-CALLPRGPATH
           if THETESTNUM > 9
              MOVE 1 TO OFFSET
           else
              MOVE 0 TO OFFSET
           end-if
           move './binTHETESTNUM/' to EZA-CALLPRGPATH(1:7+OFFSET)
           move EZA-CALLPROGRAM to EZA-CALLPRGPATH(8+OFFSET:8)
           move space to EZA-CALLPRGPATH(16+OFFSET:1)
           move SPACES to EZA-CLIENTID-TASK-STR
           move EZA-CLIENTID-TASK to EZA-CLIENTID-TASK-STR
           move EZA-CLIENTID-TASK-STR TO EZA-CALLPRGPATH(17+OFFSET:9)
           move EZA-S-ACCEPT TO EZA-CALLPRGPATH(26+OFFSET:4)
           set NULL-POINTER to NULL
           CALL 'CALLPROG' using EZA-CALLPRGPATH
           END-CALL
           move SPACES TO EZA-CALLPROGRAM
           .
       SPWANCHILD-EXIT.
           EXIT.
           
           
       EZA-RECVTMP SECTION.
       RECVTMP-START.
           MOVE 'RECV' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           MOVE LENGTH OF EZA-BUFFER TO EZA-NBYTE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-ACCEPT
               EZA-FLAGS
               EZA-NBYTE
               EZA-BUFFER
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
                     EZA-BUFFER(1:EZA-RETCODE)
                       UPON CONSOLE
           end-if
           .
           
       RECVTMP-EXIT.
           EXIT.
