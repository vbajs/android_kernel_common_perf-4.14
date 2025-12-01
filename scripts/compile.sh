#!/bin/bash
#
# Compile script for kernel
#

# Exit immediately if a command exits with a non-zero status.
set -e

# Start builtin bash timer
SECONDS=0

# --- Helper Functions ---

setup_environment() {
  echo "Setting up build environment..."
  export ARCH=arm64
  export KBUILD_BUILD_USER=build-user
  export KBUILD_BUILD_HOST=build-host
}

setup_clang() {
  echo "Setting up Clang..."

  # Setup Clang
  if [ ! -d "$PWD/clang" ]; then
    echo "Cloning Clang..."
    git clone https://gitlab.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-r547379.git --depth=1 -b 15.0 clang
  else
    echo "Local clang dir found, using it."
  fi
}

setup_path() {
  echo "Updating PATH..."
  export PATH="$PWD/clang/bin:$PATH"
}

compile_kernel() {
  echo -e "\nStarting compilation..."
  
  # 1. Make the base defconfig
  make O=out ARCH=arm64 vendor/sdmsteppe-perf_defconfig vendor/sweet.config

  # 3. Run the main build
  make -j$(nproc --all) \
    O=out \
    ARCH=arm64 \
    LLVM=1 \
    LLVM_IAS=1 \
    CROSS_COMPILE=aarch64-linux-gnu- \
    CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
}

package_output() {
  echo -e "\nPackaging outputs..."

  local kernel="out/arch/arm64/boot/Image.gz"
  local dtbo="out/arch/arm64/boot/dtbo.img"
  local dtb="out/arch/arm64/boot/dtb.img"

  if [ ! -f "$kernel" ] || [ ! -f "$dtbo" ] || [ ! -f "$dtb" ]; then
    echo -e "\nCompilation failed! Output files not found."
    exit 1
  fi

  # Copy outputs to root directory
  cp "$kernel" "./Image.gz"
  cp "$dtbo" "./dtbo.img"
  cp "$dtb" "./dtb.img"

  echo "Outputs copied to root directory"
}

print_summary() {
  echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
}

# --- Main Execution ---

main() {
  setup_environment
  setup_clang
  setup_path
  compile_kernel
  package_output
  print_summary
}

# Run the main function
main
