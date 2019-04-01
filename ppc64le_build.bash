#!/bin/bash

echo "#####################"
echo "IT IS RECOMMENDED TO RUN THIS BUILD SCRIPT ON UBUNTU BIONIC!"
echo "#####################"
echo "If any error occurs, please refer to https://wiki.raptorcs.com/wiki/Porting/Chromium for missing dependencies or others."
echo "#####################"

set -eux

mkdir -p build/download_cache
./utils/downloads.py retrieve -c build/download_cache -i downloads.ini
./utils/downloads.py unpack -c build/download_cache -i downloads.ini -- build/src

./utils/prune_binaries.py build/src pruning.list

./utils/patches.py apply build/src patches

./utils/domain_substitution.py apply -r domain_regex.list -f domain_substitution.list -c build/domsubcache.tar.gz build/src

cd build

PATH="${PWD}/ninja:${PWD}/gn/out:${PATH}"

git clone git://github.com/ninja-build/ninja.git
cd ninja
git checkout release
./configure.py --bootstrap

cd ../

git clone https://gn.googlesource.com/gn

export CC=gcc
export CXX=g++
export AR=ar

cd gn
python build/gen.py --no-sysroot
sed s/-stdlib=libstdc++//g -i out/build.ninja
ninja -C out

unset CXX
unset CC
unset AR

cd src

cd third_party/libvpx
mkdir source/config/linux/ppc64
./generate_gni.sh
cd ../../

cd third_party/ffmpeg
./chromium/scripts/build_ffmpeg.py linux ppc64
./chromium/scripts/generate_gn.py
./chromium/scripts/copy_config.sh 
cd ../../

cd ../

REVISION=$(grep -Po "(?<=CLANG_REVISION = ')\d+(?=')" tools/clang/scripts/update.py)

svn checkout --force "https://llvm.org/svn/llvm-project/llvm/trunk@$REVISION" llvm
svn checkout --force "https://llvm.org/svn/llvm-project/cfe/trunk@$REVISION" llvm/tools/clang
svn checkout --force "https://llvm.org/svn/llvm-project/compiler-rt/trunk@$REVISION" llvm/compiler-rt

mkdir llvm_build
cd llvm_build
cmake -DCMAKE_BUILD_TYPE=Release -DLLVM_TARGETS_TO_BUILD="PowerPC" -G "Unix Makefiles" ../llvm
make -j$(nproc)

cd ../
cd src

mkdir -p out/Default
cp flags.gn out/Default/args.gn
./tools/gn/bootstrap/bootstrap.py --skip-generate-buildfiles -j4 -o out/Default/gn

./out/Default/gn gen out/Default --fail-on-unused-args
ninja -C out/Default chrome chrome_sandbox
