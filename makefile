
include mkfgen/config.mkf

all: lib/libezasoket.so ${TARGET64}

lib/libezasoket.so:obj/ezasoket.o
	${CC} ${LINKOPT_SO} ${BIT32OPT} -o $@ $?

obj/ezasoket.o: src/ezasoket.c
	${CC} ${CCDYN} ${BIT32OPT} -I. -c -o $@ $?

lib64/libezasoket.so:obj64/ezasoket.o
	${CC} ${LINKOPT_SO} -m64 -o $@ $?

obj64/ezasoket.o: src/ezasoket.c
	${CC} ${CCDYN} -m64 -I. -c -o $@ $?

   
# ezasoket has very strict rules on what goes in each directory
# so this aggressive cleanup is okay:
# after you run clean you will NOT need to run ./configure, only make
clean: 
	rm -f obj/* lib/* bin/* obj64/* lib64/*
	
# after you run veryclean you will need to run ./configure
veryclean: 
	rm -f obj/* lib/* bin/* obj64/* lib64/*
	rm -f gensrc/* genmkf/*
	
