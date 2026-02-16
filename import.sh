#!/bin/sh
# Author: Mikolaj Izdebski <mizdebsk@redhat.com>
set -eu

repo_url=https://developer.download.nvidia.com/compute/cuda/repos/rhel10/x86_64

rpm_url=$(
    dnf5 -q \
        --refresh \
        --releasever 10 \
        --repofrompath nv,${repo_url} \
        --repo nv \
        --best \
        download \
        --url \
        nvidia-driver-assistant
)

curl -o nvdata.rpm "${rpm_url}"

version=$(rpm -q --qf '%{version}' -p nvdata.rpm)
echo "Version is: ${version}"

license=$(rpm -q --qf '%{license}' -p nvdata.rpm)
if [ "${license}" != "MIT" ]; then
    echo "Expected license to be MIT, but was: ${license}"
    exit 1
fi

rm -rf temp-unpack/
mkdir temp-unpack/
rpm2cpio nvdata.rpm | cpio -id -D temp-unpack/

cp temp-unpack/usr/share/licenses/nvidia-driver-assistant/LICENSE .
jq <temp-unpack/usr/share/nvidia-driver-assistant/supported-gpus/supported-gpus.json >hwdata-nv.json

cat >README.md <<EOF
## radii-hwdata-nv

Hardware database for NVIDIA GPU chips.

Version: ${version}

Based on data obtained from:
${rpm_url}

Licensed under MIT license, see the LICENSE file.
EOF

echo DONE
