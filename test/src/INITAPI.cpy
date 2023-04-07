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

       EZA-INITAPI SECTION.
       INITAPI-START.
           MOVE 'INITAPI' TO EZA-FUNCTION
           MOVE +0 TO EZA-MAXSOC
           MOVE SPACES TO EZA-IDENT
           MOVE SPACES TO EZA-SUBTASK
           MOVE +0 TO EZA-MAXSNO
           MOVE +1 TO EZA-ERRNO
           MOVE +0 TO EZA-RETCODE
           CALL 'EZASOKET'
               USING
               EZA-FUNCTION
               EZA-MAXSOC
               EZA-IDENT
               EZA-SUBTASK
               EZA-MAXSNO
               EZA-ERRNO
               EZA-RETCODE
           END-CALL
           IF EZA-RETCODE IS LESS THAN +0
               DISPLAY 'INITAPI failed with retcode ' EZA-RETCODE
                       ' errno ' EZA-ERRNO
                       UPON CONSOLE
               GO TO AB-ABEND
           END-IF
           .
       INITAPI-EXIT.
           EXIT.

