#!/bin/bash

cd color_bounds || exit

rm -rf build

mkdir build

cd build || exit

cmake -DCMAKE_BUILD_TYPE=Release ..

make
