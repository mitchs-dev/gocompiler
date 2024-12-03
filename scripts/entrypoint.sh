#!/bin/bash
set -e

runEntrypointHelp(){
  echo "Usage: entrypoint.sh <binaryName> <binaryVersion> <arch> <dev>"
  echo "Example: docker run -ti --rm -v "$PWD:/app" gocompiler:latest mybinary 1.0.0 linux true main-path"
  echo "You should pass the path which contains the main.go file as the last argument"
}


checkForAppDir=`ls -la /app 1>/dev/null 2>/dev/null || echo "ERROR"`
if [[ $checkForAppDir == "ERROR" ]]; then
  echo "ERROR: You must mount your Go project to /app"
  runEntrypointHelp
  exit 1
fi

appDir="/app"


if [[ "$1" == "help" ]] ; then
  runEntrypointHelp
  exit 0
elif [[ "$1" != "" ]]; then
  binaryName=$1
  binaryVersion=$2
  arch=$3
  mainPath=$5
  if [[ "$mainPath" == "" ]]; then
     echo "ERROR: You must pass the path which contains the main.go file as the last argument"
     runEntrypointHelp
     exit 1
  fi
  if $4 == "true"; then
    mainPath=$mainPath binaryName=$binaryName binaryVersion=$binaryVersion /usr/local/bin/generate-binary --arch $arch --dev
    chown -R 1000:1000 $appDir/binary
    chmod -R 777 $appDir/binary
    exit 0
  else
    mainPath=$mainPath binaryName=$binaryName binaryVersion=$binaryVersion /usr/local/bin/generate-binary --arch $arch
    chown -R 1000:1000 $appDir/binary
    chmod -R 777 $appDir/binary
    exit 0
  fi

else
  runEntrypointHelp
  exit 1
fi