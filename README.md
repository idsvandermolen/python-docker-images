# Python Docker image variants or how to reduce image size with 95%
This repo describes various methods to reduce Docker image size for a regular `FastAPI` Python demo app.

## Base images
To make sure we use the same base OS, we can use the following Debian Bullseye (11) based images:
* `python:3.9-bullseye` `914MB`
* `python:3.9-slim-bullseye` `125MB`
* `debian:bullseye-slim` `80.4MB`
* `gcr.io/distroless/base-debian11` `20.3MB`

Note that the distroless image is very small, it is a stripped version of Debian without a shell,
but including SSL libraries and certificates, dynamic loader and base libraries and some timezone and
locale stuff.

## Image builds
The process of the image build basically collects the final application components into the final image.
So the process is relatively simple:
* install the `FastAPI` demo app and all dependencies
* collect all app components into a build dir
* collect all shared libaries into a build dir, except the ones that are present in the final image
* optionally use UPX to compress the executable
* use `strip` where possible to strip symbols and debug info from binaries and shared libraries. We could create
"unstripped" image variants to help debugging issues.
* compile the final image

## Image variants
There are a couple tools available to collect the app components and libraries:
* `Nuitka` Python compiler compiles the app into C code and creates dynamic executable with python packages as shared
libraries. This is really an alternative python interpreter/compiler
* `cx_Freeze` compiles Python code into Python bytecode and collects dependencies and libraries
* `PyInstaller` compiles Python code into Python bytecode and collects dependencies and libraries
* `Regular` compiles Python code into Python bytecode and uses the base Python image
* `Slim` compiles Python code into Python bytecode and uses the `slimmed` Python image

## Notes
* `UPX` creates a static executable, but after decompression it becomes a dynamic
executable
* `cx_Freeze` struggles with some `uvicorn` modules and doesn't copy all (system)
libs like `libreadline.so.1`, `libexpat.so.1` and `libz.so.1`. So we need to add
a routine to copy the libraries and set `LD_LIBRARY_PATH`
* `PyInstaller` seems to be able to copy all dependant shared libraries etc. Also
can use `UPX` when available. You might need to set `LD_LIBRARY_PATH`.

## Final Image sizes
This is the output of `docker images` sorted by size:
```
REPOSITORY                        TAG             IMAGE ID       CREATED          SIZE
rest-app                          pyinstaller     2df87860d887   About an hour ago   41.4MB
rest-app                          freeze          d473482901c2   58 seconds ago      43.1MB
rest-app                          nuitka          08f487d9ba59   12 minutes ago      65.8MB
rest-app                          slim            cb9750b00759   24 hours ago        179MB
rest-app                          latest          db20cf008e29   24 hours ago        968MB
```
Note the difference between python-slim (`:slim`) images and regular python
images (`:latest`).
Also note that it is possible to create very compact images with `PyInstaller` and
Google distroless base Debian image. The base / regular Python image is 20 times larger than
the distroless image!

## TODO
* use `patchelf` Python / Linux tool to correct RPATH (removes the need for setting `LD_LIBRARY_PATH`)
* compile Python code to bytecode and remove the regular Python code
* use `python3 -mcompileall -b` for legacy `.pyc` bytecode file locations
* test `Cython`
* test `PyOxydizer`
* perhaps experiment with Python `-O` and `-OO` options
* perhaps use `UPX` everywhere
