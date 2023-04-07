       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           GETHOST2.

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
            01 HOSTNAME PIC X(16).
            01 HOSTNAME-LEN PIC 9(8) COMPBINARY.
      *     01 HOSTENT  PIC 9(8) BINARY.
            01 HOSTENT  POINTER.
            
            01 HOSTNAME-LENGTH   PIC 9(4) COMPBINARY. 
            01 HOSTNAME-VALUE    PIC X(255). 
            01 HOSTALIAS-COUNT   PIC 9(4) COMPBINARY. 
            01 HOSTALIAS-SEQ     PIC 9(4) COMPBINARY. 
            01 HOSTALIAS-LENGTH  PIC 9(4) COMPBINARY. 
            01 HOSTALIAS-VALUE   PIC X(255). 
            01 HOSTADDR-TYPE     PIC 9(4) COMPBINARY. 
            01 HOSTADDR-LENGTH   PIC 9(4) COMPBINARY. 
            01 HOSTADDR-COUNT    PIC 9(4) COMPBINARY. 
            01 HOSTADDR-SEQ      PIC 9(4) COMPBINARY. 
            01 HOSTADDR-VALUE    PIC 9(8) COMPBINARY. 

       LINKAGE SECTION.
            01 HOSTENT-INFO.
               05 HOSTENT-HOSTNAME USAGE IS POINTER.
               05 HOSTENT-ALIAS-LIST USAGE IS POINTER.
               05 HOSTENT-FAMILY PIC 9(8) COMPBINARY.
               05 HOSTENT-HOSTADDR-LEN PIC 9(8) COMPBINARY.
               05 HOSTENT-HOSTADDR-LIST USAGE IS POINTER.
            01 HOSTNAME-STR PIC X(255) VALUES LOW-VALUES.
       PROCEDURE DIVISION.

            
       MAINLINE.

           MOVE 'GETHOST2' TO EZA-PROGRAM
           PERFORM EZA-INITAPI
           PERFORM EZA-GETHOSTBYNAME
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY INITAPI.
           COPY TERMAPI.
           COPY ABEND.
           
           
       EZA-GETHOSTBYNAME SECTION.
       GETHOSTBYNAME-START.
           MOVE 'GETHOSTBYNAME' TO EZA-FUNCTION    
           MOVE '127.0.0.1' TO HOSTNAME
           MOVE 9 TO HOSTNAME-LEN
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               HOSTNAME-LEN 
               HOSTNAME
               HOSTENT
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: GETHOSTBYNAME returned wrong'
              GO TO AB-ABEND
           ELSE
              move 0 to HOSTALIAS-SEQ
              move 0 to HOSTADDR-SEQ
              move 0 to HOSTALIAS-COUNT
              perform EZA-OUTPUTENT 
           END-IF
           DISPLAY 'COMPLETE'
           .

       GETHOSTBYNAME-EXIT.
           EXIT.

       EZA-OUTPUTENT  SECTION.
       OUTPUTENT-START.
         CALL 'EZACIC08' USING HOSTENT
                       HOSTNAME-LENGTH 
                       HOSTNAME-VALUE 
                       HOSTALIAS-COUNT 
                       HOSTALIAS-SEQ 
                       HOSTALIAS-LENGTH 
                       HOSTALIAS-VALUE 
                       HOSTADDR-TYPE 
                       HOSTADDR-LENGTH 
                       HOSTADDR-COUNT 
                       HOSTADDR-SEQ 
                       HOSTADDR-VALUE 
                       EZA-RETCODE
         END-CALL
         IF EZA-RETCODE IS LESS THAN  +0 
            display 'FAIL: CONVERT HOSTENV RETURN: ', EZA-RETCODE
         ELSE
            display 'PASS TO CONVERT HOSTENV'
            display "hostname is: ", HOSTNAME-VALUE (1:HOSTNAME-LENGTH)
            display "address length is: ", HOSTADDR-LENGTH
            if HOSTALIAS-SEQ = HOSTALIAS-COUNT 
               perform EZA-OUTPUTENT
            end-if
            
         END-IF
         .
       OUTPUTENT-EXIT.
           EXIT.
