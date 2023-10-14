#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y git-core gnupg flex bison build-essential zip curl zlib1g-dev  \
    libc6-dev-i386 libncurses5 x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev  \
    libxml2-utils xsltproc unzip fontconfig python3 npm pip e2fsprogs python3-protobuf \
    fonts-dejavu diffutils rsync ccache

npm install --global yarn

mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
ln -s /usr/bin/python3 /usr/bin/python