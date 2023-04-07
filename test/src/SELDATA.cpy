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
           05   SEL-R-SND-ARY.
             10 SEL-R-SND-ARY-ENTRY  PIC X(1)      OCCURS 60 TIMES.
           05   SEL-R-SND-STR        REDEFINES
                SEL-R-SND-ARY        PIC X(60).
           05   SEL-R-SND-MSK.
             10 SEL-R-SND-MSK-ENTRY  PIC 9(9) COMPBINARY OCCURS 2 TIMES.

           05   SEL-W-SND-ARY.
             10 SEL-W-SND-ARY-ENTRY  PIC X(1)      OCCURS 60 TIMES.
           05   SEL-W-SND-STR        REDEFINES
                SEL-W-SND-ARY        PIC X(60).
           05   SEL-W-SND-MSK.
             10 SEL-W-SND-MSK-ENTRY  PIC 9(9) COMPBINARY OCCURS 2 TIMES.

           05   SEL-E-SND-ARY.
             10 SEL-E-SND-ARY-ENTRY  PIC X(1)      OCCURS 60 TIMES.
           05   SEL-E-SND-STR        REDEFINES
                SEL-E-SND-ARY        PIC X(60).
           05   SEL-E-SND-MSK.
             10 SEL-E-SND-MSK-ENTRY  PIC 9(9) COMPBINARY OCCURS 2 TIMES.

           05   SEL-R-RTN-ARY.
             10 SEL-R-RTN-ARY-ENTRY  PIC X(1)      OCCURS 60 TIMES.
           05   SEL-R-RTN-STR        REDEFINES
                SEL-R-RTN-ARY        PIC X(60).
           05   SEL-R-RTN-MSK.
             10 SEL-R-RTN-MSK-ENTRY  PIC 9(9) COMPBINARY OCCURS 2 TIMES.

           05   SEL-W-RTN-ARY.
             10 SEL-W-RTN-ARY-ENTRY  PIC X(1)      OCCURS 60 TIMES.
           05   SEL-W-RTN-STR        REDEFINES
                SEL-W-RTN-ARY        PIC X(60).
           05   SEL-W-RTN-MSK.
             10 SEL-W-RTN-MSK-ENTRY  PIC 9(9) COMPBINARY OCCURS 2 TIMES.

           05   SEL-E-RTN-ARY.
             10 SEL-E-RTN-ARY-ENTRY  PIC X(1)      OCCURS 60 TIMES.
           05   SEL-E-RTN-STR        REDEFINES
                SEL-E-RTN-ARY        PIC X(60).
           05   SEL-E-RTN-MSK.
             10 SEL-E-RTN-MSK-ENTRY  PIC 9(9) COMPBINARY OCCURS 2 TIMES.

           05  SEL-MAX-SOC   PIC 9(8)  COMPBINARY VALUE 60.
           05  SEL-S         PIC 9(8).
           05  SEL-TOKEN     PIC X(16).
           05  SEL-RET-CODE  PIC S9(8) COMPBINARY.
           05  SEL-TIMEOUT.
               10 SEL-TIMEOUT-SECONDS   PIC S9(8) COMPBINARY. 
               10 SEL-TIMEOUT-MICROSEC  PIC S9(8) COMPBINARY.

