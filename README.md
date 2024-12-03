# gocompiler

This is a docker image which can be used to compile GO binaries for multiple OS's. This image is based on the official `golang` image. Currently this image only supports GO `1.19.1`.


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