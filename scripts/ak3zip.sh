#!/bin/bash
#
# Package kernel into flashable zip using AnyKernel3
#

# Exit immediately if a command exits with a non-zero status.
set -e

# Setting up AnyKernel3
if [ ! -d AnyKernel3 ]; then
  git clone -q https://github.com/galadriel1402/AnyKernel3 -b master AnyKernel3
fi

# Copy kernel outputs into AnyKernel3
cp Image.gz dtbo.img dtb.img AnyKernel3/

# Modify anykernel.sh to replace device names
sed -i "s/device\.name1=.*/device.name1=sweet/" AnyKernel3/anykernel.sh
sed -i "s/device\.name2=.*/device.name2=sweetin/" AnyKernel3/anykernel.sh

cd AnyKernel3
zip -r9 "../$ZIPNAME" * -x .git
cd ..

rm -rf AnyKernel3

echo "Packaging complete: $ZIPNAME"
