#!/bin/bash

mkdir -p build

for file in $(find . -name "*.s"); do
  obj=$(basename "$file" .s)
  as -g -I include "$file" -o build/"$obj".o
done

ld build/*.o -o awm

echo "Build complete"
