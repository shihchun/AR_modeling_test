# Install GSL

download from [gsl official ](https://www.gnu.org/software/gsl/) - [gsl-latest.tar.gz](https://mirror.ossplanet.net/gnu/gsl/gsl-latest.tar.gz)

## build from source

```sh
wget https://mirror.ossplanet.net/gnu/gsl/gsl-latest.tar.gz
tar -jxvf gsl-lastest.tar.gz
mkdir gsl
cd /gsl-latest/gsl-2.6
./configure --prefix=/home/geek/gsl
make
sudo make install
```

## install with package

```sh
sudo pacman -S gsl
sudo apt install libgsl-dev
```



build the test file, ubuntu and manjaro need to add the `-lpthread`, to let the pathread.h works.

 ```sh
g++ -std=c++11 gsl_test.cc -L/home/geek/gsl/lib -I/home/geek/gsl/include  -lgsl -lgslcblas -lpthread
# -I include *.h
# -L include libs, have conmand gsl-config ..etc
./a.out

gsl-config --prefix # install with apt-get or pacman
/usr/local
g++ -std=c++11 ar_rate.cc -L/usr/local/lib -I/usr/local/include/gsl  -lgsl -lgslcblas -lpthread
 ```

# install in windows & MacOS

In windows install msys2

```sh
choco install msys2
mingw64.exe
pacman -S mingw-w64-x86_64-toolchain
pacman -S mingw-w64-x86_64-gsl
cd /d/your_working directory
g++ -std=c++11 gsl_test.cc -lgsl -lgslcblas
./a.out
```

Add msys2 to cmder, need a lot settings. ignore...

```sh
(base) λ where mingw64.exe
C:\tools\msys64\mingw64.exe
... to be continued
```

If use the visual studio check the [Ref](https://solarianprogrammer.com/2020/01/26/getting-started-gsl-gnu-scientific-library-windows-macos-linux/)

In macos just do 

```sh
brew install gsl
g++ -std=c++11 gsl_test.cc -lgsl -lgslcblas
./a.out
```

