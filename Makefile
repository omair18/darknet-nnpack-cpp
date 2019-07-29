GPU=0
CUDNN=0
OPENCV=1
nnpack=1
nnpack_FAST=1
ARM_NEON=0
OPENMP=1
DEBUG=0
QPU_GEMM=0

ARCH= -gencode arch=compute_30,code=sm_30 \
      -gencode arch=compute_35,code=sm_35 \
      -gencode arch=compute_50,code=[sm_50,compute_50] \
      -gencode arch=compute_52,code=[sm_52,compute_52]
#      -gencode arch=compute_20,code=[sm_20,sm_21] \ This one is deprecated?

# This is what I use, uncomment if you know your arch and want to specify
# ARCH= -gencode arch=compute_52,code=compute_52

VPATH=./src/:./examples
SLIB=libdarknet.so
ALIB=libdarknet.a
EXEC=darknet
OBJDIR=./obj/

CC=gcc
NVCC=nvcc 
AR=ar
ARFLAGS=rcs
OPTS=-Ofast
LDFLAGS= -lm -pthread -lm
COMMON= -Iinclude/ -Isrc/
#CFLAGS=-Wall -Wno-unknown-pragmas -Wfatal-errors -fPIC
#CFLAGS=-Wall -Wno-unknown-pragmas -Wfatal-errors -fPIC -march=native -mfpmath=sse
CFLAGS=-Wall -Wno-unknown-pragmas -Wfatal-errors -fPIC -march=native -lm

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
LDFLAGS+= `pkg-config --libs opencv` -lstdc++  -lm

COMMON+= `pkg-config --cflags opencv` 
endif

ifeq ($(GPU), 1) 
COMMON+= -DGPU -I/usr/local/cuda/include/
CFLAGS+= -DGPU
LDFLAGS+= -L/usr/local/cuda/lib64 -lcuda -lcudart -lcublas -lcurand
endif

ifeq ($(CUDNN), 1) 
COMMON+= -DCUDNN 
CFLAGS+= -DCUDNN
LDFLAGS+= -lcudnn 
endif

ifeq ($(QPU_GEMM), 1) 
COMMON+= -DQPU_GEMM
CFLAGS+= -DQPU_GEMM
LDFLAGS+= -lqmkl
endif

ifeq ($(nnpack), 1)
COMMON+= -Dnnpack
CFLAGS+= -Dnnpack
LDFLAGS+= -lnnpack -lpthreadpool -lm
endif

ifeq ($(nnpack_FAST), 1)
COMMON+= -Dnnpack_FAST
CFLAGS+= -Dnnpack_FAST
endif

ifeq ($(ARM_NEON), 1)
COMMON+= -DARM_NEON
CFLAGS+= -DARM_NEON -mfpu=neon-vfpv4 -funsafe-math-optimizations -ftree-vectorize
endif

OBJ=gemm.o utils.o cuda.o deconvolutional_layer.o convolutional_layer.o list.o image.o activations.o im2col.o col2im.o blas.o crop_layer.o dropout_layer.o maxpool_layer.o softmax_layer.o data.o matrix.o network.o connected_layer.o cost_layer.o parser.o option_list.o detection_layer.o route_layer.o upsample_layer.o box.o normalization_layer.o avgpool_layer.o layer.o local_layer.o shortcut_layer.o logistic_layer.o activation_layer.o rnn_layer.o gru_layer.o crnn_layer.o demo.o batchnorm_layer.o region_layer.o reorg_layer.o tree.o  lstm_layer.o l2norm_layer.o yolo_layer.o
EXECOBJA=captcha.o lsd.o super.o art.o tag.o cifar.o go.o rnn.o segmenter.o regressor.o classifier.o coco.o yolo.o detector.o nightmare.o darknet.o

ifeq ($(GPU), 1) 
LDFLAGS+= -lstdc++
OBJ+=convolutional_kernels.o deconvolutional_kernels.o activation_kernels.o im2col_kernels.o col2im_kernels.o blas_kernels.o crop_layer_kernels.o dropout_layer_kernels.o maxpool_layer_kernels.o avgpool_layer_kernels.o
endif

EXECOBJ = $(addprefix $(OBJDIR), $(EXECOBJA))
OBJS = $(addprefix $(OBJDIR), $(OBJ))
DEPS = $(wildcard src/*.h) Makefile include/darknet.h
nnpackOBJS = ../nnpack/build/src/convolution-inference.c.o ../nnpack/build/src/convolution-input-gradient.c.o ../nnpack/build/src/convolution-kernel-gradient.c.o ../nnpack/build/src/convolution-output.c.o ../nnpack/build/src/fully-connected-inference.c.o ../nnpack/build/src/fully-connected-output.c.o ../nnpack/build/src/init.c.o ../nnpack/build/src/pooling-output.c.o ../nnpack/build/src/relu-input-gradient.c.o ../nnpack/build/src/relu-output.c.o ../nnpack/build/src/softmax-output.c.o ../nnpack/build/src/ref/convolution-input-gradient.c.o ../nnpack/build/src/ref/convolution-kernel.c.o ../nnpack/build/src/ref/convolution-output.c.o ../nnpack/build/src/ref/fully-connected-output.c.o ../nnpack/build/src/ref/max-pooling-output.c.o ../nnpack/build/src/ref/relu-input-gradient.c.o ../nnpack/build/src/ref/relu-output.c.o ../nnpack/build/src/ref/softmax-output.c.o ../nnpack/build/src/ref/fft/aos.c.o ../nnpack/build/src/ref/fft/forward-dualreal.c.o ../nnpack/build/src/ref/fft/forward-real.c.o ../nnpack/build/src/ref/fft/inverse-dualreal.c.o ../nnpack/build/src/ref/fft/inverse-real.c.o ../nnpack/build/src/scalar/2d-fourier-16x16.c.o ../nnpack/build/src/scalar/2d-fourier-8x8.c.o ../nnpack/build/src/scalar/2d-winograd-8x8-3x3.c.o ../nnpack/build/src/scalar/fft-aos.c.o ../nnpack/build/src/scalar/fft-dualreal.c.o ../nnpack/build/src/scalar/fft-real.c.o ../nnpack/build/src/scalar/fft-soa.c.o ../nnpack/build/src/scalar/relu.c.o ../nnpack/build/src/scalar/softmax.c.o ../nnpack/build/src/scalar/blas/cgemm.c.o ../nnpack/build/src/scalar/blas/cgemm-conjb.c.o ../nnpack/build/src/scalar/blas/cgemm-conjb-transc.c.o ../nnpack/build/src/scalar/blas/conv1x1.c.o ../nnpack/build/src/scalar/blas/s2gemm.c.o ../nnpack/build/src/scalar/blas/s2gemm-transc.c.o ../nnpack/build/src/scalar/blas/sdotxf.c.o ../nnpack/build/src/scalar/blas/sgemm.c.o ../nnpack/build/src/scalar/blas/shdotxf.c.o ../nnpack/build/src/x86_64-fma/2d-fourier-16x16.py.o ../nnpack/build/src/x86_64-fma/2d-fourier-8x8.py.o ../nnpack/build/src/x86_64-fma/2d-winograd-8x8-3x3.py.o ../nnpack/build/src/x86_64-fma/fft-aos.py.o ../nnpack/build/src/x86_64-fma/fft-dualreal.py.o ../nnpack/build/src/x86_64-fma/fft-real.py.o ../nnpack/build/src/x86_64-fma/fft-soa.py.o ../nnpack/build/src/x86_64-fma/ifft-dualreal.py.o ../nnpack/build/src/x86_64-fma/ifft-real.py.o ../nnpack/build/src/x86_64-fma/max-pooling.py.o ../nnpack/build/src/x86_64-fma/relu.py.o ../nnpack/build/src/x86_64-fma/softmax.c.o ../nnpack/build/src/x86_64-fma/softmax.py.o ../nnpack/build/src/x86_64-fma/winograd-f6k3.py.o ../nnpack/build/src/x86_64-fma/blas/c8gemm.py.o ../nnpack/build/src/x86_64-fma/blas/conv1x1.py.o ../nnpack/build/src/x86_64-fma/blas/s4c6gemm.py.o ../nnpack/build/src/x86_64-fma/blas/s8gemm.py.o ../nnpack/build/src/x86_64-fma/blas/sdotxf.py.o ../nnpack/build/src/x86_64-fma/blas/sgemm.py.o ../nnpack/build/src/x86_64-fma/blas/shdotxf.py.o
#all: obj backup results $(SLIB) $(ALIB) $(EXEC)
all: obj  results $(SLIB) $(ALIB) $(EXEC)


$(EXEC): $(EXECOBJ) $(ALIB)
	$(CC) $(COMMON) $(CFLAGS) -lm $^ -o $@ $(LDFLAGS) $(ALIB)

$(ALIB): $(OBJS)
	$(AR) $(ARFLAGS) $@ $^

$(SLIB): $(OBJS) $(nnpackOBJS)
	$(CC) $(CFLAGS)  -shared $^ -lm /usr/lib/libpthreadpool.a $(LDFLAGS) -o $@

$(OBJDIR)%.o: %.c $(DEPS)
	$(CC) $(COMMON) $(CFLAGS) -c $< -o $@

$(OBJDIR)%.o: %.cu $(DEPS)
	$(NVCC) $(ARCH) $(COMMON) --compiler-options "$(CFLAGS)" -c $< -o $@

obj:
	mkdir -p obj
backup:
	mkdir -p backup
results:
	mkdir -p results

.PHONY: clean

clean:
	rm -rf $(OBJS) $(SLIB) $(ALIB) $(EXEC) $(EXECOBJ)

