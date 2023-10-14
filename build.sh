#!/bin/bash
export PATH=~/bin:$PATH
set -e

retry() {
  set +e
  local max_attempts=${ATTEMPTS-5}
  local timeout=${TIMEOUT-1}
  local attempt=0
  local exitCode=0

  while [[ $attempt < $max_attempts ]]
  do
    "$@"
    exitCode=$?

    if [[ $exitCode == 0 ]]
    then
      break
    fi

    echo "Failure! Retrying ($*) in $timeout.."
    sleep "${timeout}"
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ $exitCode != 0 ]]
  then
    echo "Failed too many times! ($*)"
  fi

  set -e

  return $exitCode
}

DEVICE=$1
TARGET=$2

# set git identity
git config --global user.email "someone@somewhere.com"
git config --global user.name "Someone"

retry curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

mkdir -p /aosp
cd /aosp
retry yes | repo init -u https://github.com/GrapheneOS/platform_manifest.git -b 14 --depth=1
retry repo sync -c -j4 --fail-fast --force-sync

yarn install --cwd vendor/adevtool/
source build/envsetup.sh
m aapt2

vendor/adevtool/bin/run generate-all -d $DEVICE

source build/envsetup.sh
lunch $DEVICE-$TARGET

export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 20G
ccache -o compression=true
ccache -z

m -j4 vendorbootimage target-files-package