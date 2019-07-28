# README #

This project uses [Darknet](https://github.com/pjreddie/darknet) library and Deep Neural Network (DNN) to detect and recognize objects. It uses C++ as base language.

[Darknet](https://pjreddie.com/darknet/) is a framework used to train DNN model.

### What is this repository for? ###

This repository is for everyone who is interesting in computer vision and how to integrate [Darknet](https://github.com/pjreddie/darknet) in custom application.

Repository is non-commercial open-sourced and free to use and contribute.

### How do I get set up? ###

* This project developed on Ubuntu 16.04 LTS and didn't ran or tested on different environment.
* **Dependencies**: C++ 14, [Darknet](https://github.com/pjreddie/darknet), [cmake](https://cmake.org/).

Make sure [Darknet installed](https://pjreddie.com/darknet/install/) as described in theirs web page.

### How do I run it? ###

Create directory to clone project to and clone source code:
```
~$ mkdir DarknetApp
~$ cd DarknetApp/
~/DarknetApp$ git clone git clone git@bitbucket.org:ChernyshovYuriy/darknetapp.git ~/DarknetApp/
```
Create directory to build project to and build project:
```
~/DarknetApp$ mkdir build
~/DarknetApp$ cd build
```
Run cmake to compile project:
```
~/DarknetApp/build$ cmake -DCMAKE_BUILD_TYPE=Debug -G "CodeBlocks - Unix Makefiles" ../
```
Run cmake to build binary executable:
```
~/DarknetApp/build$ cmake --build . --target DarknetApp -- -j4
```
Run project:
```
cd ../
~/DarknetApp$ build/DarknetApp
```

### Who do I talk to? ###

Project owner and admin - Yurii Chernyshov

E-mail : chernyshov.yuriy@gmail.com

LinkedIn: https://www.linkedin.com/in/yurii-chernyshov/
