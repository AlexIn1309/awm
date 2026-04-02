#!/bin/bash
# ============================================================
# build.sh - Build script for AWM
#
# Assembles all .s files and links them into a single binary.
# ============================================================

set -e  # Exit on error

echo "=== AWM Build Script ==="
echo ""

# Create build directory
mkdir -p build

# Clean previous build
echo "[1/3] Cleaning previous build..."
rm -f build/*.o awm

# Assemble all source files
echo "[2/3] Assembling source files..."
for file in $(find . -name "*.s" -type f); do
    obj=$(basename "$file" .s)
    echo "    Assembling: $file"
    as -g -I include "$file" -o "build/${obj}.o"
done

# Link all object files
echo ""
echo "[3/3] Linking..."
ld build/*.o -o awm

echo ""
echo "=== Build complete! ==="
echo "Run with: ./awm"
