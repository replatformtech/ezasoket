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

       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           PRINTHEX.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
         01 SrcIndex     PIC 9(8).
         01 DstIndex     PIC 9(8).
         01 RghtIndex    PIC 9(8).
         01 LeftIndex    PIC 9(8).
         01 DSTLEN       PIC 9(8).
                   
      *  TmpNum is a type BINARY value so that it can
      *  be redefined on top of a pic X and not cause truncation.
      *  Had it been defined as a COMP value there would be truncation.
         01 TmpNum PIC 9(4) BINARY.
         
         01 HEX-TABLE   PIC X(16) VALUE
                      '0123456789ABCDEF'.
                      
         01 FILLER REDEFINES HEX-TABLE.
            05 HEX-CHAR PIC X(01) OCCURS 16.
            
         01 TMP-START PIC 9(8) COMP.
         01 TMP-END PIC 9(8) COMP.
         01 TMP-STEP PIC 9(8) COMP.

       LINKAGE SECTION.

         01 DST.
            05 DST-BUFF PIC X 
                        OCCURS 1 TO 1000 TIMES DEPENDING ON DSTLEN.
            
         01 SRC.
            05 SRC-BUFF PIC X 
                        OCCURS 1 TO 1000 TIMES DEPENDING ON SRCLEN.
         
         01 SRCLEN PIC 9(8) COMP.
         
       PROCEDURE DIVISION USING DST SRC SRCLEN.

       MAINLINE.

           MOVE SRCLEN TO TMP-END
           ADD 1 TO TMP-END
           MOVE 1 TO TMP-START
           MOVE 1 To TMP-STEP
           
           MULTIPLY SRCLEN BY 2 GIVING DSTLEN
           MOVE 0 To DstIndex
           perform varying SrcIndex From TMP-START by TMP-STEP until
                                       SrcIndex = TMP-END      

               ADD 2 To DSTINDEX
               Compute TmpNum = Function ORD (SRC-BUFF(SrcIndex)) - 1
          
      *        DISPLAY "n=" TmpNum

      *        Use a math trick to extract the left and right nybble:
               DIVIDE TmpNum BY 16 GIVING RghtIndex REMAINDER LeftIndex

      *        Add 1 because COBOL indexes start with 1
               ADD 1 to LeftIndex
               ADD 1 to RghtIndex
      *        DISPLAY "r =" RghtIndex " l=" LeftIndex
               
      *        DISPLAY LENGTH OF TmpNum
      *        DISPLAY RghtIndex, LeftIndex
               MOVE HEX-CHAR(LeftIndex) TO DST-BUFF(DstIndex)
               SUBTRACT 1 FROM DstIndex
               MOVE HEX-CHAR(RghtIndex) TO DST-BUFF(DstIndex)
               ADD 1 TO DstIndex
               
           end-perform
           GOBACK
           .

