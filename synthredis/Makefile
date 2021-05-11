SRC_BENCH=bench.cpp Timer.cpp zipf.cpp numalib.cpp  

LDLIBS=-lpthread -lnuma

BUILDDIR=build
INCLUDEDIR=include
APPS=bench 
DEPS=

OBJ_BENCH=$(SRC_BENCH:%.cpp=$(BUILDDIR)/%.o)
APPS_TARGET=$(APPS:%=$(BUILDDIR)/%)

# Path and dir of this makefile
MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

KAPI_DIR=${MKFILE_DIR}../../pbmem/include

CC=g++
CFLAGS=-c -std=c++17 -I$(INCLUDEDIR) -Werror -Wall -pedantic -Wno-unused-variable -faligned-new -O3 -ggdb3 -I$(KAPI_DIR)
LDFLAGS=-ggdb3 -ldl

all: $(APPS_TARGET)

$(BUILDDIR)/%.o: %.cpp $(DEPS)
	$(CC) -o $@ $< $(CFLAGS)

$(BUILDDIR)/bench: $(OBJ_BENCH) $(DEPS)
	$(CC) -o $@ $^ $(LDFLAGS) $(LDLIBS)

$(shell   mkdir -p $(BUILDDIR))

.PHONY: clean
clean:
	rm -f $(BUILDDIR)/*.o $(BUILDDIR)/$(APPS) 
