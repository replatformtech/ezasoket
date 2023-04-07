       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           TAKE0050.

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

      * test TAKESOCKET
         COPY EZADATA.
         01 EZA-S-RECV PIC 9(4) COMPBINARY.
         01 EZA-S-RECV-STR PIC X(4).
         01 EZA-S-RECV-BUFF REDEFINES EZA-S-RECV-STR 
                            PIC X OCCURS 4.
         01 TmpNum PIC 9(4) BINARY.
         
         01 DigitalStr PIC X(10) VALUES '0123456789'.
         01 DigitalBuff REDEFINES DigitalStr
                        PIC X OCCURS 10.
         
         01 EZA-CLIENTID. 
              05 EZA-CLIENTID-DOMAIN PIC 9(8) COMPBINARY. 
              05 EZA-CLIENTID-NAME PIC X(8). 
              05 EZA-CLIENTID-TASK PIC X(8). 
              05 EZA-CLIENTID-RESERVED PIC X(20).

         01 para-cnt PIC 9(05).
       PROCEDURE DIVISION.

       MAINLINE.

           DISPLAY "start to run take0050" UPON CONSOLE
           MOVE 'TAKE0050' TO EZA-PROGRAM
           PERFORM PARSECMDLINE.
           PERFORM EZA-INITAPI.
           PERFORM EZA-TAKESOCKET.
           PERFORM EZA-RECV.
           PERFORM EZA-CLOSE.
           PERFORM EZA-TERMAPI.
           GOBACK
           .
           
           COPY INITAPI.
           COPY CLOSE.
           COPY TERMAPI.
           COPY ABEND.
           
       PARSECMDLINE SECTION.
       PARSECMDLINE-START.
      *  set clientid to SPACES by default
            MOVE SPACES TO EZA-CLIENTID
            ACCEPT para-cnt FROM ARGUMENT-NUMBER 
            END-ACCEPT
            DISPLAY " Parameters cnt:" para-cnt 
            ACCEPT EZA-CLIENTID-TASK FROM ARGUMENT-VALUE
            END-ACCEPT
            DISPLAY "clientid task: " EZA-CLIENTID-TASK
            ACCEPT EZA-S-RECV-STR FROM ARGUMENT-VALUE
            END-ACCEPT
      *     convert the string the number
            perform varying TmpNum from 1 by 1 until 
               TmpNum = 11 or DigitalBuff(TmpNum) = EZA-S-RECV-BUFF(1)
            end-perform
            SUBTRACT 1 FROM TmpNum
            MULTIPLY TmpNum BY 1000 GIVING TmpNum
            ADD TmpNum TO EZA-S-RECV
            perform varying TmpNum from 1 by 1 until 
               TmpNum = 11 or DigitalBuff(TmpNum) = EZA-S-RECV-BUFF(2)
            end-perform
            SUBTRACT 1 FROM TmpNum
            MULTIPLY TmpNum BY 100 GIVING TmpNum
            ADD TmpNum TO EZA-S-RECV
            perform varying TmpNum from 1 by 1 until 
               TmpNum = 11 or DigitalBuff(TmpNum) = EZA-S-RECV-BUFF(3)
            end-perform
            SUBTRACT 1 FROM TmpNum
            MULTIPLY TmpNum BY 10 GIVING TmpNum
            ADD TmpNum TO EZA-S-RECV
            perform varying TmpNum from 1 by 1 until 
               TmpNum = 11 or DigitalBuff(TmpNum) = EZA-S-RECV-BUFF(4)
            end-perform
            SUBTRACT 1 FROM TmpNum
            ADD TmpNum TO EZA-S-RECV
            DISPLAY "recvsock is:" EZA-S-RECV
            .
       PARSECMDLINE-EXIT.
           EXIT.
       
       ConvertChrToDigital.
         
       
       EZA-RECV SECTION.
       RECV-START.
           MOVE 'RECV' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           MOVE +0 TO EZA-FLAGS
           MOVE LENGTH OF EZA-BUFFER TO EZA-NBYTE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S
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
              if EZA-BUFFER(1:EZA-RETCODE) EQUAL
                 'TEST SEND FROM CALL0050'
                 DISPLAY 'PASS: expected return from call0050.cbl'
              else
                 DISPLAY 'Receive message is:' EZA-BUFFER(1:EZA-RETCODE)
                 DISPLAY 'FAIL: unexpected return from call0050.cbl'
              end-if
              DISPLAY 'COMPLETE'
           end-if
           .

       RECV-EXIT.
           EXIT.
           
       EZA-TAKESOCKET SECTION.
       TAKESOCKET-START.
           MOVE 'TAKESOCKET' TO EZA-FUNCTION
           MOVE +0 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-S-RECV
               EZA-CLIENTID
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           if EZA-RETCODE IS LESS THAN +0
              display "FAIL: takesocket return with: ", 
                       EZA-ERRNO
                       UPON CONSOLE
              GO TO AB-ABEND
           else
              display "takesocket return with socket handle: ",
                       EZA-RETCODE UPON CONSOLE
              move EZA-RETCODE to EZA-S
           end-if
           .

       TAKESOCKET-EXIT.
           EXIT.
