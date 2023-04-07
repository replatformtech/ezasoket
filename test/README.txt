This directory contains the regression tests for ezasoket library.

The instructions for running the tests are:
1) cd trunk/test
2) ./compile
3) ./runtests
4) For each FAIL or INCOMPLETE:
   look in the FAIL directory for the output of the test.

Here are some additional notes:

A) To add support for an additional COBOL compiler change ./compile.
   There should be no need to change ./runtests.

B) The src directory contains the COBOL source code that are the tests.

c) The bin directory contains the executible code from the COBOL source
   being compiled.

D) The tests directory contains scripts that invoke the COBOL programs.
   One and only one script per test.

E) The runtests script evaluates the success of a test based on the lack
   of a FAIL message and the presence of a COMPLETE message.

F) Sometimes the FAIL/PASS/COMPLETE messages are output by the
   COBOL program (error001.cbl) and sometimes they are output by the
   script (dumphost.ksh).

G) A COBOL program could be used by more than one test.

H) Some tests are to confirm that a particular error is generated
   for a particular situation.  In this case the presence of an
   error is a PASS for the test.

