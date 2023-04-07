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

       UTILITY SECTION.
       AB-0001.
           MOVE 0001 TO ABEND-CODE.
           GO TO AB-ABEND.


       AB-ABEND.
           DISPLAY '*ABEND*  ' EZA-PROGRAM  UPON CONSOLE
           DISPLAY 'FUNCTION=' EZA-FUNCTION UPON CONSOLE
           DISPLAY 'ERROR=   ' EZA-ERRNO    UPON CONSOLE
           GOBACK
           .
       AB-EXIT.
           EXIT.
