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

       EZA-TERMAPI SECTION.
       TERMAPI-START.
           MOVE 'TERMAPI' TO EZA-FUNCTION.
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'TERMAPI failed with retcode ' EZA-RETCODE
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
               GO TO AB-ABEND
           END-IF
           .
       TERMAPI-EXIT.
           EXIT.

