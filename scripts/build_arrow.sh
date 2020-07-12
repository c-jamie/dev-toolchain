#!/bin/bash
ASAN=OFF
UBSAN=OFF
while [[ "$#" -gt 0 ]]; do
    case $1 in
        # -d|--deploy) deploy="$2"; shift ;;
        -f|--fast) FAST=1 ;;
        -a|--asan) ASAN=ON; UBSAN=ON ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

export CONDA_HOME=~/miniconda
eval "$($CONDA_HOME/bin/conda shell.bash hook)"

mkdir -p ~/code/arrow/cpp/build
mkdir -p ~/code/arrow/cpp/build/dist
pushd ~/code/arrow/cpp/build

conda activate a37
echo == USING PYTHON ==
which python

export ARROW_HOME=~/code/arrow/cpp/build/dist
export LD_LIBRARY_PATH=$ARROW_HOME/lib:$LD_LIBRARY_PATH

cmake -DCMAKE_BUILD_TYPE=debug -DARROW_BUILD_TESTS=ON -DARROW_COMPUTE=ON -DARROW_DATASET=ON  -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang -DCMAKE_INSTALL_PREFIX=$ARROW_HOME -DARROW_PYTHON=ON -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DARROW_USE_ASAN=$ASAN -DARROW_USE_UBSAN=$UBSAN ..

if [ $FAST = 1 ]; then
    echo == BUILD MODE MULTI ==
    make -j24
else
    echo == BUILD MODE SINGLE ===
    make
fi

make install