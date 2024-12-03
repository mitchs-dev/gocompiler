#!/bin/bash
DATE=`date +%Y-%m-%d`
appDir="/app"
cd $appDir

# REQUIRED: Set the binary name as an environment variable
if [[ "$binaryName" == "" ]]; then
  echo "ERROR: binaryName is not set"
  exit 1
fi
# REQUIRED: Set the binary version as an environment variable
if [[ "$binaryVersion" == "" ]]; then
  echo "ERROR: binaryVersion is not set"
  exit 1
fi

if [[ "$mainPath" == "" ]]; then
  mainPath="/app"
  echo "mainPath is not set, using default: $mainPath"
fi

rm -rf binary
mkdir -p binary/sha256
echo "-------------------------"
echo "Working Directory: $PWD"
echo "Main Path: $mainPath"
echo "Binary Name: $binaryName"
echo "Binary Version: $binaryVersion"
echo "Binary Timestamp: $DATE"
echo "CGO_ENABLED: $CGO_ENABLED"
echo "-------------------------"
echo "App Directory: $PWD"
ls -la
echo "-------------------------"
cd $mainPath
echo "Main Directory: $PWD"
ls -la
echo "-------------------------"
mkdir -p ./binary/sha256

if [[ $* == *--arch* ]]; then
   if [[ $* == *linux* ]]; then
      if [[ $* == *--dev* ]]; then
         env GOOS=linux GOARCH=amd64 go build -o ./binary/$binaryName-linux-amd64-$binaryVersion-$DATE-DEVBUILD
         touch ./binary/sha256/$binaryName-linux-amd64-$binaryVersion-$DATE-DEVBUILD.sha256
         sha256sum ./binary/$binaryName-linux-amd64-$binaryVersion-$DATE-DEVBUILD  | cut -d ' ' -f 1 > ./binary/sha256/$binaryName-linux-amd64-$binaryVersion-$DATE-DEVBUILD.sha256
      else
         env GOOS=linux GOARCH=amd64 go build -o ./binary/$binaryName-linux-amd64-$binaryVersion
         touch ./binary/sha256/$binaryName-linux-amd64-$binaryVersion.sha256
         sha256sum ./binary/$binaryName-linux-amd64-$binaryVersion  | cut -d ' ' -f 1 > ./binary/sha256/$binaryName-linux-amd64-$binaryVersion.sha256
      fi
      echo "Generated Linux Binary 🐧"
      mkdir -p /app/binary
      mv ./binary /app/binary
      exit 0
   elif [[ $* == *mac* ]]; then
      if [[ $* == *--dev* ]]; then
         env GOOS=darwin GOARCH=amd64 go build -o ./binary/$binaryName-darwin-amd64-$binaryVersion-$DATE-DEVBUILD
         touch ./binary/sha256/$binaryName-darwin-amd64-$binaryVersion-$DATE-DEVBUILD.sha256
         sha256sum ./binary/$binaryName-darwin-amd64-$binaryVersion-$DATE-DEVBUILD  | cut -d ' ' -f 1 > ./binary/sha256/$binaryName-darwin-amd64-$binaryVersion-$DATE-DEVBUILD.sha256
         env GOOS=darwin GOARCH=arm64 go build -o ./binary/$binaryName-darwin-arm64-$binaryVersion-$DATE-DEVBUILD
         touch ./binary/sha256/$binaryName-darwin-arm64-$binaryVersion-$DATE-DEVBUILD.sha256
         sha256sum ./binary/$binaryName-darwin-arm64-$binaryVersion-$DATE-DEVBUILD  | cut -d ' ' -f 1 > ./binary/sha256/$binaryName-darwin-arm64-$binaryVersion-$DATE-DEVBUILD.sha256

      else
         env GOOS=darwin GOARCH=amd64 go build -o ./binary/$binaryName-darwin-amd64-$binaryVersion
         touch ./binary/sha256/$binaryName-darwin-amd64-$binaryVersion.sha256
         sha256sum ./binary/$binaryName-darwin-amd64-$binaryVersion | cut -d ' ' -f 1 > ./binary/sha256/$binaryName-darwin-amd64-$binaryVersion.sha256
         env GOOS=darwin GOARCH=arm64 go build -o ./binary/$binaryName-darwin-arm64-$binaryVersion
         touch ./binary/sha256/$binaryName-darwin-arm64-$binaryVersion.sha256
         sha256sum ./binary/$binaryName-darwin-arm64-$binaryVersion | cut -d ' ' -f 1 > ./binary/sha256/$binaryName-darwin-arm64-$binaryVersion.sha256
      fi
      echo "Generated Mac OSX Binary 🍎"
      mkdir -p /app/binary
      mv ./binary /app/binary
      exit 0
   elif [[ $* == *windows* ]]; then
      if [[ $* == *--dev*  ]]; then
         env GOOS=windows GOARCH=amd64 go build -o ./binary/$binaryName-$binaryVersion-$DATE-DEVBUILD.exe
         touch ./binary/sha256/$binaryName-$binaryVersion-$DATE-DEVBUILD-windows.sha256
         sha256sum ./binary/$binaryName-$binaryVersion-$DATE-DEVBUILD.exe  | cut -d ' ' -f 1 > ./binary/sha256/$binaryName-$binaryVersion-$DATE-DEVBUILD-windows.sha256
      else
         env GOOS=windows GOARCH=amd64  go build -o ./binary/$binaryName-$binaryVersion.exe
         touch ./binary/sha256/$binaryName-$binaryVersion-windows.sha256
         sha256sum ./binary/$binaryName-$binaryVersion.exe  | cut -d ' ' -f 1 > ./binary/sha256/$binaryName-$binaryVersion-windows.sha256
      fi
      echo "Generated Windows Binary 🪟"
      mkdir -p /app/binary
      mv ./binary /app
      exit 0
   fi
else
   echo "You should run ./scripts/generate-binary.sh --arch <linux/mac/windows>"
   echo "You can also run '--dev' to create a 'Devlopment Build'"
   exit 0
fi
