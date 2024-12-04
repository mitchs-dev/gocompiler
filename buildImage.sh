#!/bin/bash

registry="docker.io"
imageRepo="vo1d"
imageName="gocompiler"
supportedVersionFile=".supported-versions"

set -e

build_image() {
  local imageVersion=$1
  local isLatest=$2

  # Extract major, minor, and patch versions
  IFS='.' read -r major minor patch <<< "$imageVersion"
  # Decrement the patch version to get the previous tag
  previousPatch=$((patch - 1))
  previousTag="$major.$minor.$previousPatch"

  echo "========================================"
  echo "Processing version: $imageVersion (Latest: $isLatest)"
  echo "========================================"
  echo "Building GO Compiler with CGO disabled"
  docker build --cache-from $registry/$imageRepo/$imageName:$previousTag \
    --build-arg CGO_ENABLED=0 \
    --build-arg GO_VERSION=$imageVersion \
    -t $registry/$imageRepo/$imageName:$imageVersion \
    $( [ "$isLatest" == "true" ] && echo "-t $registry/$imageRepo/$imageName:latest" ) . && \
  echo "Successfully built GO Compiler with CGO disabled for version $imageVersion"
  
  echo "Building GO Compiler with CGO enabled"
  docker build --cache-from $registry/$imageRepo/$imageName:$previousTag-cgo \
    --build-arg CGO_ENABLED=1 \
    --build-arg GO_VERSION=$imageVersion \
    -t $registry/$imageRepo/$imageName:$imageVersion-cgo \
    $( [ "$isLatest" == "true" ] && echo "-t $registry/$imageRepo/$imageName:latest-cgo" ) . && \
  echo "Successfully built GO Compiler with CGO enabled for version $imageVersion"
  
  if [[ $DISABLE_PUSH == 1 ]]; then
    echo "Skipping push..exiting"
    exit 0
  fi
  
  if [[ "$3" == "--push" ]]; then
    echo "Pushing GO Compiler to $registry"
    docker push $registry/$imageRepo/$imageName:$imageVersion && \
    docker push $registry/$imageRepo/$imageName:$imageVersion-cgo && \
    $( [ "$isLatest" == "true" ] && echo "docker push $registry/$imageRepo/$imageName:latest && docker push $registry/$imageRepo/$imageName:latest-cgo" ) && \
    echo "Successfully pushed GO Compiler for version $imageVersion to $registry"
  else
    echo "Skipping push to $registry/$imageRepo"
  fi
  echo "========================================"
  echo "Completed processing version: $imageVersion (Latest: $isLatest)"
  echo "========================================"
}

export -f build_image
export registry imageRepo imageName DISABLE_PUSH

# Iterate through the available versions
versions=()
while IFS= read -r line; do
  # Skip lines that start with a comment
  if [[ $line == \#* ]]; then
    continue
  fi

  # Extract the major and minor version
  majorMinorVersion=$(echo $line | grep -oP '^\d+\.\d+')

  # Check if majorMinorVersion is not empty
  if [[ -n $majorMinorVersion ]]; then
    # Expand the brace expressions and iterate through the versions
    expandedVersions=$(echo $line | sed -E 's/^[0-9]+\.[0-9]+\.//; s/[{}]//g; s/,/ /g')
    for patchVersion in $expandedVersions; do
      if [[ $patchVersion == *@ ]]; then
        versions+=("$majorMinorVersion.${patchVersion%@} true")
      else
        versions+=("$majorMinorVersion.$patchVersion false")
      fi
    done
  fi
done < $supportedVersionFile

# Get the number of CPU cores and divide by 2
num_cores=$(($(nproc) / 2))

# Run the builds in parallel with progress tracking and limited concurrency
parallel --jobs $num_cores --bar --colsep ' ' build_image ::: "${versions[@]}"