######################################

# Makefile written by Zev Kronenberg #

#     zev.kronenberg@gmail.com       #

######################################



CC=g++
GCC=gcc
GIT_VERSION := $(shell git describe --abbrev=4 --dirty --always)
CFLAGS= -Wall -DVERSION=\"$(GIT_VERSION)\" -std=c++0x 
INCLUDE=-Isrc/lib -Isrc/bamtools/include -Isrc/bamtools/src -Isrc/ -Isrc/fastahack -Isrc/Complete-Striped-Smith-Waterman-Library/src/ -Isrc/seqan/core/include/ -Isrc/seqan/extras/include
OUTFOLD=bin/
LIBS=-L./ -lbamtools -fopenmp -lz -lm 
RUNTIME=-Wl,-rpath=src/bamtools/lib/



all: mvSSW createBin bamtools libbamtools.a buildWHAMBAM whamGraph buildMerge clean
debug: mvSSW createBin bamtools libbamtools.a buildWHAMBAMD graphDebug buildMerge clean

mvSSW:
	cp src/lib/ssw.c src/Complete-Striped-Smith-Waterman-Library/src
createBin:
	-mkdir bin
bamtools:
	cd src/bamtools && mkdir -p build && cd build && cmake .. && make
libbamtools.a: bamtools
	cp src/bamtools/lib/libbamtools.a .
FASTA.o:
	cd src/fastahack && make
ssw_cpp.o:
	cd src/Complete-Striped-Smith-Waterman-Library/src && make

SSW = src/Complete-Striped-Smith-Waterman-Library/src/ssw_cpp.o src/Complete-Striped-Smith-Waterman-Library/src/ssw.o
FASTAHACK = src/fastahack/Fasta.o                                                                                                                                                                           
buildWHAMBAM: libbamtools.a FASTA.o ssw_cpp.o
	$(CC) $(CFLAGS) src/lib/*cpp src/bin/multi-wham-testing.cpp $(INCLUDE) $(LIBS) $(FASTAHACK) $(SSW)  -o $(OUTFOLD)WHAM-BAM $(RUNTIME)
buildWHAMBAMD: libbamtools.a FASTA.o ssw_cpp.o
	$(CC) $(CFLAGS) -g -DDEBUG src/lib/*cpp src/bin/multi-wham-testing.cpp $(INCLUDE) $(LIBS) $(FASTAHACK) $(SSW) -o $(OUTFOLD)WHAM-BAM $(RUNTIME)
buildWHAMDUMPER:
	$(CC) $(CFLAGS) -g src/lib/*cpp   src/bin/multi-wham.cpp $(INCLUDE) $(LIBS) -o $(OUTFOLD)WHAM-BAM-DUMPER $(RUNTIME)
buildWHAMBAMGENE:
	$(CC) $(CFLAGS) -g src/lib/*cpp  src/bin/multi-wham-testing-gene.cpp  $(INCLUDE) $(LIBS) -o $(OUTFOLD)WHAM-BAM-GENE $(RUNTIME)
whamGraph:
	$(CC) $(CFLAGS)  -O3 src/lib/*cpp src/bin/graph-er.cpp src/lib/gauss.c $(INCLUDE) $(LIBS) $(FASTAHACK) $(SSW)  -o $(OUTFOLD)WHAM-GRAPHENING $(RUNTIME)
graphDebug:
	$(CC) $(CFLAGS) -g -DDEBUG src/lib/*cpp src/bin/graph-er.cpp src/lib/gauss.c $(INCLUDE) $(LIBS) $(FASTAHACK) $(SSW)  -o $(OUTFOLD)WHAM-GRAPHENING $(RUNTIME)

buildTest:
	$(CC) -g -I/home/zkronenb/tools/gtest-1.7.0/include/ -L/home/zkronenb/tools/gtest-1.7.0/build -
buildMerge:
	$(CC) $(CFLAGS) $(INCLUDE) $(LIBS) src/bin/mergeIndv.cpp src/lib/split.cpp -o $(OUTFOLD)mergeIndvs


clean:
	-@rm *.a