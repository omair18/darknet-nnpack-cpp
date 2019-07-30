This repo adds CPP support with an example case in `cpp/`


# Darknet with NNPACK compiled for CPP
NNPACK was used to optimize [Darknet](https://github.com/pjreddie/darknet) without using a GPU. It is useful for embedded devices using ARM CPUs.

Idein's [qmkl](https://github.com/Idein/qmkl) is also used to accelerate the SGEMM using the GPU. This is slower than NNPACK on NEON-capable devices, and primarily useful for ARM CPUs without NEON.

The NNPACK implementation in Darknet was improved to use transform-based convolution computation, allowing for 40%+ faster inference performance on non-initial frames. This is most useful for repeated inferences, ie. video, or if Darknet is left open to continue processing input instead of allowed to terminate after processing input.

## CPP Example
CPP example is located inside  `cpp/`  folder. 
Make sure to update darknet paths in `CMakelists.txt`.

After following the Build Instructions, navigate to `cpp/` and run `cmake . && make`

## Build Instructions
Log in to Raspberry Pi using SSH.<br/>
Install [PeachPy](https://github.com/Maratyszcza/PeachPy) and [confu](https://github.com/Maratyszcza/confu)
```
sudo apt-get install python-pip
sudo pip install --upgrade git+https://github.com/Maratyszcza/PeachPy
sudo pip install --upgrade git+https://github.com/Maratyszcza/confu
```
### Install [Ninja](https://ninja-build.org/)
```
git clone https://github.com/ninja-build/ninja.git
cd ninja
git checkout release
./configure.py --bootstrap
export NINJA_PATH=$PWD
```
Install clang (I'm not sure why we need this, NNPACK doesn't use it unless you specifically target it).
```
sudo apt-get install clang
```
### Install modified [NNPACK](https://github.com/shizukachan/NNPACK)
```
git clone https://github.com/digitalbrain79/NNPACK-darknet.git NNPACK
cd NNPACK
confu setup
python ./configure.py --backend auto
```
Update cflags & cxxflags in `build.ninja`.(Add ` -fPIC ` option.)

```
cflags = -std=gnu99 -g -pthread -fPIC
cxxflags = -std=gnu++11 -g -pthread -fPIC
```
Build NNPACK
```
$NINJA_PATH/ninja
```
Copy libs & header files to `/usr/`
```
sudo cp -a lib/* /usr/lib/ && \ 
sudo cp include/nnpack.h /usr/include/ && \ 
sudo cp deps/pthreadpool/include/pthreadpool.h /usr/include/
```

### Build Darknet-NNPACK 
To avoid linker issues while compiling CPP wrapper, add all the *.o files of NNPACK compiled above in the Darknet's `Makefile`. Make sure to update the paths accordingly.

```
NNPACKOBJS = ../NNPACK/build/src/convolution-inference.c.o ../NNPACK/build/src/convolution-input-gradient.c.o ../NNPACK/build/src/convolution-kernel-gradient.c.o ../NNPACK/build/src/convolution-output.c.o ../NNPACK/build/src/fully-connected-inference.c.o ../NNPACK/build/src/fully-connected-output.c.o ../NNPACK/build/src/init.c.o ../NNPACK/build/src/pooling-output.c.o ../NNPACK/build/src/relu-input-gradient.c.o ../NNPACK/build/src/relu-output.c.o ../NNPACK/build/src/softmax-output.c.o ../NNPACK/build/src/ref/convolution-input-gradient.c.o ../NNPACK/build/src/ref/convolution-kernel.c.o ../NNPACK/build/src/ref/convolution-output.c.o ../NNPACK/build/src/ref/fully-connected-output.c.o ../NNPACK/build/src/ref/max-pooling-output.c.o ../NNPACK/build/src/ref/relu-input-gradient.c.o ../NNPACK/build/src/ref/relu-output.c.o ../NNPACK/build/src/ref/softmax-output.c.o ../NNPACK/build/src/ref/fft/aos.c.o ../NNPACK/build/src/ref/fft/forward-dualreal.c.o ../NNPACK/build/src/ref/fft/forward-real.c.o ../NNPACK/build/src/ref/fft/inverse-dualreal.c.o ../NNPACK/build/src/ref/fft/inverse-real.c.o ../NNPACK/build/src/x86_64-fma/2d-fourier-16x16.py.o ../NNPACK/build/src/x86_64-fma/2d-fourier-8x8.py.o ../NNPACK/build/src/x86_64-fma/2d-winograd-8x8-3x3.py.o ../NNPACK/build/src/x86_64-fma/fft-aos.py.o ../NNPACK/build/src/x86_64-fma/fft-dualreal.py.o ../NNPACK/build/src/x86_64-fma/fft-real.py.o ../NNPACK/build/src/x86_64-fma/fft-soa.py.o ../NNPACK/build/src/x86_64-fma/ifft-dualreal.py.o ../NNPACK/build/src/x86_64-fma/ifft-real.py.o ../NNPACK/build/src/x86_64-fma/max-pooling.py.o ../NNPACK/build/src/x86_64-fma/relu.py.o ../NNPACK/build/src/x86_64-fma/softmax.c.o ../NNPACK/build/src/x86_64-fma/softmax.py.o ../NNPACK/build/src/x86_64-fma/winograd-f6k3.py.o ../NNPACK/build/src/x86_64-fma/blas/c8gemm.py.o ../NNPACK/build/src/x86_64-fma/blas/conv1x1.py.o ../NNPACK/build/src/x86_64-fma/blas/s4c6gemm.py.o ../NNPACK/build/src/x86_64-fma/blas/s8gemm.py.o ../NNPACK/build/src/x86_64-fma/blas/sdotxf.py.o ../NNPACK/build/src/x86_64-fma/blas/sgemm.py.o ../NNPACK/build/src/x86_64-fma/blas/shdotxf.py.o
.
.
.

$(SLIB): $(OBJS) $(NNPACKOBJS)
	$(CC) $(CFLAGS) -shared $^ -lm /usr/lib/libpthreadpool.a -o $@ 
```
Build darknet

``` make -j4 ```

## Test
The weight files can be downloaded from the [YOLO homepage](https://pjreddie.com/darknet/yolo/).
```
YOLOv2
./darknet detector test cfg/coco.data cfg/yolo.cfg yolo.weights data/person.jpg
Tiny-YOLO
./darknet detector test cfg/voc.data cfg/tiny-yolo-voc.cfg tiny-yolo-voc.weights data/person.jpg
```
## Original NNPACK CPU-only Results (Raspberry Pi 3)
Model | Build Options | Prediction Time (seconds)
:-:|:-:|:-:
YOLOv2 | NNPACK=1,ARM_NEON=1 | 8.2
YOLOv2 | NNPACK=0,ARM_NEON=0 | 156
Tiny-YOLO | NNPACK=1,ARM_NEON=1 | 1.3
Tiny-YOLO | NNPACK=0,ARM_NEON=0 | 38

## Improved NNPACK CPU-only Results (Raspberry Pi 3)
All NNPACK=1 results use march=native, pthreadpool is initialized for one thread for the single core Pi Zero, and mcpu=cortex-a53 for the Pi 3.

For non-implicit-GEMM convolution computation, it is possible to precompute the kernel to accelerate subsequent inferences. The first inference is slower than later ones, but the speedup is significant (40%+). This optimization is a classic time-memory tradeoff; YOLOv2 won't fit in the Raspberry Pi 3's memory with this code.

System | Model | Build Options | Prediction Time (seconds)
:-:|:-:|:-:|:-:
Pi 3 | YOLOv3-Tiny VOC | NNPACK=1,ARM_NEON=1,NNPACK_FAST=1 | 1.1 (first frame), 0.73 (subsequent frames)
Pi 3 | Tiny-YOLO | NNPACK=1,ARM_NEON=1,NNPACK_FAST=1 | 1.4 (first frame), 0.82 (subsequent frames)
Pi 3 | Tiny-YOLO | NNPACK=1,ARM_NEON=1,NNPACK_FAST=0 | 1.2
Pi 3 | Darknet 224x224 | NNPACK=1,ARM_NEON=1,NNPACK_FAST=1 | 1.7 (first frame), 0.77 (subsequent frames)
Pi 3 | Darknet 224x224 | NNPACK=1,ARM_NEON=1,NNPACK_FAST=0 | 0.93
Pi 3 | Darknet 256x256 | NNPACK=1,ARM_NEON=1,NNPACK_FAST=1 | 1.8 (first frame), 0.87 (subsequent frames)
Pi 3 | Darknet19 224x224 | NNPACK=1,ARM_NEON=1,NNPACK_FAST=1 | 5.3 (first frame), 2.7 (subsequent frames)
Pi 3 | Darknet19 224x224 | NNPACK=1,ARM_NEON=1,NNPACK_FAST=0 | 3.8
Pi 3 | Darknet19 256x256 | NNPACK=1,ARM_NEON=1,NNPACK_FAST=1 | 5.8 (first frame), 3.1 (subsequent frames)
i5-3320M | Tiny-YOLO | NNPACK=1,NNPACK_FAST=1 | 0.27 (first frame), 0.17 (subsequent frames)
i5-3320M | Tiny-YOLO | NNPACK=1,NNPACK_FAST=0 | 0.42
i5-3320M | Tiny-YOLO | NNPACK=0, no OpenMP | 1.4
i5-3320M | YOLOv2 | NNPACK=1,NNPACK_FAST=1 | 0.98 (first frame), 0.69 (subsequent frames)
i5-3320M | YOLOv2 | NNPACK=1,NNPACK_FAST=0 | 1.4
i5-3320M | YOLOv2 | NNPACK=0, no OpenMP | 5.5

Apparently cfg files have changed with yolov3 update, so benchmarks may be out of date, ie. classifier network input size. This has been updated for the classifier networks Darknet and Darknet19 only.

On the Intel chip, using transformed GEMM is always faster, even with precomputation on the first frame, than implicit-GEMM. On the Pi 3, implicit-GEMM is faster on the first frame. This suggests that memory bandwidth may be a limiting factor on the Pi 3.

## NNPACK+QPU_GEMM Results
I used these NNPACK cache tunings for the Pi 3:
```
L1 size: 32k / associativity: 4 / thread: 1
L2 size: 480k / associativity: 16 / thread: 4 / inclusive: false
L3 size: 2016k / associativity: 16 / thread: 1 / inclusive: false
This should yield l1.size=32, l2.size=120, and l3.size=2016 after NNPACK init is run.
```
And these for the Pi Zero:
```
L1 size: 16k / associativity: 4 / thread: 1
L2 size: 128k / associativity: 4 / thread: 1 / inclusive: false
L3 size: 128k / associativity: 4 / thread: 1 / inclusive: false
This should yield l1.size=16, l2.size=128, and l3.size=128 after NNPACK init is run.
```
Even though the Pi Zero's L2 is attached to the QPU and almost as slow as main memory, it does seem to have a small benefit.

Raspberry Pi | Model | Build Options | Prediction Time (seconds)
:-:|:-:|:-:|:-:
Pi 3 | Tiny-YOLO | NNPACK=1,ARM_NEON=1,QPU_GEMM=1 | 5.3
Pi Zero | Tiny-YOLO | NNPACK=1,QPU_GEMM=1 | 7.7
Pi Zero | Tiny-YOLO | NNPACK=1,QPU_GEMM=0 | 28.2
Pi Zero | Tiny-YOLO | NNPACK=0,QPU_GEMM=0 | 124
Pi Zero | Tiny-YOLO | NNPACK=0,QPU_GEMM=1 | 8.0
Pi Zero | Darknet19 224x224 | NNPACK=1,QPU_GEMM=1 | 3.3
Pi Zero | Darknet19 224x224 | NNPACK=1,QPU_GEMM=0 | 22.3
Pi Zero | Darknet19 224x224 | NNPACK=0,QPU_GEMM=1 | 3.5
Pi Zero | Darknet19 224x224 | NNPACK=0,QPU_GEMM=0 | 96.3
Pi Zero | Darknet 224x224 | NNPACK=1,QPU_GEMM=1 | 1.23
Pi Zero | Darknet 224x224 | NNPACK=1,QPU_GEMM=0 | 4.15
Pi Zero | Darknet 224x224 | NNPACK=0,QPU_GEMM=1 | 1.32
Pi Zero | Darknet 224x224 | NNPACK=0,QPU_GEMM=0 | 14.9

On the Pi 3, the QPU is slower than NEON-NNPACK. qmkl is just unable to match the performance NNPACK's extremely well tuned NEON implicit GEMM.

On the Pi Zero, the QPU is faster than scalar-NNPACK. I have yet to investigate why enabling NNPACK gives a very slight speedup on the Pi Zero.

## GPU / config.txt considerations
Using the QPU requires memory set aside for the GPU. Using the command `sudo vcdbg reloc` you can see how much memory is free on the GPU - it's roughly 20MB less than what is specified by gpu_mem.

I recommend no less than gpu_mem=80 if you want to run Tiny-YOLO/Darknet19/Darknet. The code I've used tries to keep GPU allocations to a minimum, but if Darknet crashes before GPU memory is freed, it will be gone until a reboot.

