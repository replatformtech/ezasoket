       IDENTIFICATION DIVISION.
       PROGRAM-ID.
           WRITE002.

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

       PROCEDURE DIVISION.

       MAINLINE.

           MOVE 5002       TO EZA-NAME-PORT
           MOVE 'WRITE002' TO EZA-PROGRAM
           MOVE 'TEST SEND FROM WRITE002' TO EZA-BUFFER
           MOVE 23         TO EZA-NBYTE

           PERFORM EZA-INITAPI.
           PERFORM EZA-SOCKET.
           PERFORM EZA-CONNECT.
           PERFORM EZA-WRITE.
           PERFORM EZA-CLOSE.
           PERFORM EZA-TERMAPI.
           GOBACK.

           COPY INITAPI.
           COPY SOCKET.
           COPY CONNECT.
           COPY WRITE.
           COPY CLOSE.
           COPY TERMAPI.
           COPY ABEND.

