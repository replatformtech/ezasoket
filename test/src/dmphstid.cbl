       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           DMPHSTID.

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
            01 EZA-HOSTID.
               05 EZA-HOSTID-NUMBER   PIC S9(8) COMPBINARY.
               05 EZA-HOSTID-UNINUMBER   PIC S9(8) COMP.
                                    
            01 DST    PIC X(8).
            01 SRCLEN PIC 9(8)  COMP VALUE 4.

            01 REVERT-FIELD PIC 9(8) COMPBINARY VALUES 1.
            
       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 'LISTEN07' TO EZA-PROGRAM
           MOVE 5007       TO EZA-NAME-PORT

           PERFORM EZA-INITAPI
           PERFORM EZA-GETHOSTID
         
           PERFORM EZA-TERMAPI
           GOBACK
           .

           COPY INITAPI.
           COPY TERMAPI.
           COPY ABEND.
           
           
       EZA-GETHOSTID SECTION.
       GETHOSTID-START.
           MOVE 'GETHOSTID' TO EZA-FUNCTION
           MOVE 1 TO EZA-HOSTID-NUMBER
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-HOSTID-NUMBER
           END-CALL
           MOVE EZA-HOSTID-NUMBER TO EZA-HOSTID-UNINUMBER
           CALL 'PRINTHEX' USING DST EZA-HOSTID-UNINUMBER SRCLEN 
                                 REVERT-FIELD 
           END-CALL
           DISPLAY 'HOSTID IS: ',DST
           
           .

       GETHOSTID-EXIT.
           EXIT.
