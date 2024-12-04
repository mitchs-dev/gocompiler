# gocompiler

This is a docker image which can be used to compile GO binaries for multiple OS's. This image is based on the official `golang` image.

> **IMPORTANT**: This image has previously gone through an overhaul. If you previously used a `1.0.0` version of this image, please be aware that the new tags are going to reflect the version of GO that is being used. (I.e `1.23.3`)

## Supported Versions

This image will follow the GO Release Policy and will support the last 3 minor versions of GO: https://go.dev/doc/devel/release#policy

## How to use

```bash
docker run -ti --rm -v "<path-to-go-project>/app" vo1d/gocompiler:latest <binary-name> <binary-version> <os-name> <set-dev-build>
```

* `<path-to-go-project>` - This should be the root of your GO project
   * If you are currently in the root of your GO project, you can just do `$PWD` for this value
* `<binary-name>` - Name of the binary which is generated
* `<binary-version>` - Version of the binary which will be generated
* `<os-name>` - OS to build binary for (Linux, Darwin, Windows)
* `<set-dev-build>` - true/false to add `-DEV` to the end of the binary name

## Building with CGO enabled

The default image does not have CGO enabled. If you need to build with CGO enabled, you can add `-cgo` to the end of the tag to pull the image with CGO enabled. 

Example: `vo1d/gocompiler:latest-cgo`

## Build image

You can build the image by simply running `./buildImage.sh`