       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           GETHOST1.

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
            01 HOSTADDR PIC 9(8) COMPBINARY. 
            01 HOSTADDR-STR REDEFINES HOSTADDR
                            PIC X(4).
      *     01 HOSTENT PIC 9(8) COMPBINARY VALUES 0.
            01 HOSTENT USAGE IS POINTER..
            01 HOSTNAME-LEN PIC 9(8) COMPBINARY VALUES 0.

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
            
            01 IPV4ADDRESS PIC X(15).
            01 REVERT-FIELD PIC 9(8) COMPBINARY VALUES 1.
	    01 NUMBER-LOOPS      PIC 9(4) COMPBINARY.
       LINKAGE SECTION.
           
                   
       PROCEDURE DIVISION.

            
       MAINLINE.

           MOVE 'GETHOST1' TO EZA-PROGRAM
           PERFORM EZA-INITAPI
           PERFORM EZA-GETHOSTBYADDR
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY INITAPI.
           COPY TERMAPI.
           COPY ABEND.
           
           
       EZA-GETHOSTBYADDR SECTION.
       GETHOSTBYADDR-START.
           MOVE 'GETHOSTBYADDR' TO EZA-FUNCTION
	   MOVE 0 TO NUMBER-LOOPS
      *I think the input should be this: 
      * this doesn't work for COMP-5
      *    MOVE X'7f000001' TO HOSTADDR-STR
           MOVE 2130706433 TO HOSTADDR
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               HOSTADDR
               HOSTENT
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
              DISPLAY 'FAIL: GETHOSTBYADDR returned wrong'
              GO TO AB-ABEND
           ELSE   
              move 0 to HOSTALIAS-SEQ
              move 0 to HOSTADDR-SEQ
              move 0 to HOSTALIAS-COUNT
	      ADD 1 TO NUMBER-LOOPS
	      DISPLAY NUMBER-LOOPS
	      if NUMBER-LOOPS > 255
		 DISPLAY "FAIL: NUMBER OF LOOPS EXCEEDED"
		 GO TO AB-ABEND
	      end-if
              perform EZA-OUTPUTENT 
           END-IF
           DISPLAY 'COMPLETE'
           .

       GETHOSTBYADDR-EXIT.
           EXIT.
           
           
       EZA-OUTPUTENT  SECTION.
       OUTPUTENT-START.
	 MOVE 0 TO NUMBER-LOOPS
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
            display 'FAIL: convert hostenv return: ', EZA-RETCODE
         ELSE
            display 'PASS TO CONVERT HOSTENV'
            display "hostname is: ", HOSTNAME-VALUE (1:HOSTNAME-LENGTH)
            display "address length is: ", HOSTADDR-LENGTH
            if HOSTALIAS-SEQ = HOSTALIAS-COUNT 
	      ADD 1 TO NUMBER-LOOPS
	      DISPLAY NUMBER-LOOPS
	      if NUMBER-LOOPS > 255
		 DISPLAY "FAIL: NUMBER OF LOOPS EXCEEDED"
		 GO TO AB-ABEND
	      end-if
               perform EZA-OUTPUTENT
            end-if
         END-IF
         DISPLAY HOSTALIAS-COUNT, HOSTALIAS-SEQ
         .
       OUTPUTENT-EXIT.
           EXIT.
