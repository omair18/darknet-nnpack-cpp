GPU=0
CUDNN=0
OPENCV=1
OPENMP=1
DEBUG=0

VPATH=./myproj2
SLIB=../libdarknet.so
ALIB=../libdarknet.so
EXEC=main2
OBJDIR=./myobj2/

CC=gcc
CPP=g++ -std=c++11
OPTS=-Ofast
LDFLAGS= -lm -pthread 
COMMON= -I../include/ -Isrc/
CFLAGS=-Wall -Wno-unused-result -Wno-unknown-pragmas -Wfatal-errors -fPIC

ifeq ($(OPENMP), 1) 
CFLAGS+= -fopenmp
endif

ifeq ($(DEBUG), 1) 
OPTS=-O0 -g
endif

CFLAGS+=$(OPTS)

ifeq ($(OPENCV), 1) 
COMMON+= -DOPENCV
CFLAGS+= -DOPENCV
LDFLAGS+= `pkg-config --libs opencv` -lstdc++
COMMON+= `pkg-config --cflags opencv` 
endif

ifeq ($(GPU), 1) 
COMMON+= -DGPU -I/usr/local/neumoai/cuda8.0/include
CFLAGS+= -DGPU
LDFLAGS+= -L/usr/local/neumoai/cuda8.0/lib64 -lcuda -lcudart -lcublas -lcurand
endif

ifeq ($(CUDNN), 1) 
COMMON+= -DCUDNN 
CFLAGS+= -DCUDNN
LDFLAGS+= -lcudnn
endif

EXECOBJA= detect_obj.o main.o

ifeq ($(GPU), 1) 
LDFLAGS+= -lstdc++ 
endif

EXECOBJ = $(addprefix $(OBJDIR), $(EXECOBJA))

DEPS = $(wildcard myproj2/*.h) Makefile-myproj2 ../include/darknet.h

#all: obj results  $(EXEC)
all: obj  $(SLIB) $(ALIB) $(EXEC)


$(EXEC): $(EXECOBJ) $(ALIB)
	$(CPP) $(COMMON) $(CFLAGS) $^ -o $@ $(LDFLAGS) $(ALIB)

$(OBJDIR)%.o: %.cpp $(DEPS)
	$(CPP) $(COMMON) $(CFLAGS) -c $< -o $@

$(OBJDIR)%.o: %.c $(DEPS)
	$(CC) $(COMMON) $(CFLAGS) -c $< -o $@

$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) $(ARCH) $(COMMON) --compiler-options "$(CFLAGS)" -c $< -o $@

obj:
	mkdir -p myobj2



.PHONY: clean

clean:
	rm -rf  $(EXEC) $(EXECOBJ)

