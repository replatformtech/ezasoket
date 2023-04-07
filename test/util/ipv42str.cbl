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
           IPV42STR.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
         01 SrcIndex     PIC 9(8).
         01 DstIndex     PIC 9(8).
         01 RghtIndex    PIC 9(8).
         01 LeftIndex    PIC 9(8).
         01 DSTLEN       PIC 9(8).
         
         01 TmpCh        PIC X.
         01 FILLER redefines TmpCh.
            05 TmpNum PIC 9(2) BINARY.
            
         01 DECI-TABLE   PIC X(10) VALUE
                         '0123456789'.
                      
         01 FILLER REDEFINES DECI-TABLE.
            05 DECI-CHAR PIC X(01) OCCURS 10.
          
       LINKAGE SECTION.

         01 DST.
            05 DST-BUFF PIC X OCCURS 15.
                        
         01 SRC PIC 9(8) COMP.
         01 SRC-BUFF REDEFINES SRC PIC X OCCURS 4.
         
         01 REVERT PIC 9(8) COMP.
         01 REVERT-BUFF REDEFINES REVERT PIC X OCCURS 4.

       PROCEDURE DIVISION USING DST SRC REVERT.

       MAINLINE.
           IF REVERT-BUFF(1) = X'01' THEN
              MOVE SRC-BUFF(1) TO TmpCh
              MOVE SRC-BUFF(4) TO SRC-BUFF(1)
              MOVE TmpCh TO SRC-BUFF(4)
              MOVE SRC-BUFF(2) TO TmpCh
              MOVE SRC-BUFF(3) TO SRC-BUFF(2)
              MOVE TmpCh TO SRC-BUFF(3)
           END-IF           
           perform varying DstIndex From 1 by 1 until
                                       DstIndex = 16
               MOVE SPACE TO DST-BUFF(DstIndex)                   
           end-perform                                        
           MOVE 1 TO DstIndex
           perform varying SrcIndex From 1 by 1 until
                                       SrcIndex = 5                  
               MOVE SRC-BUFF(SrcIndex) TO TmpCh
               Compute TmpNum = Function ORD (SRC-BUFF(SrcIndex)) - 1

      *        Use a math trick to extract the left and right nybble:
               DIVIDE TmpNum BY 10 GIVING RghtIndex REMAINDER LeftIndex
               DIVIDE RghtIndex BY 10 GIVING TmpNum REMAINDER RghtIndex
               
               IF TmpNum not equal 0 THEN
                  add 1 to TmpNum
                  MOVE DECI-CHAR(TmpNum) TO DST-BUFF(DstIndex)
                  add 1 to DstIndex
               END-IF
               
               IF RghtIndex not equal 0 THEN
                  add 1 to RghtIndex
                  MOVE DECI-CHAR(RghtIndex) TO DST-BUFF(DstIndex)
                  add 1 to DstIndex
               END-IF
               
               
               add 1 to LeftIndex
               MOVE DECI-CHAR(LeftIndex) TO DST-BUFF(DstIndex)
               add 1 to DstIndex

               
               IF SrcIndex not equal 4 THEN
                  MOVE '.' TO DST-BUFF(DstIndex)
                  add 1 to DstIndex
               END-IF
           end-perform

           GOBACK
           .

