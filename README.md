# Notes
We can use `python:3.9-bullseye` or `python:3.9-slim-bullseye` as main python images.
We can use `debian:bullseye-slim` if we want a shell or else it is better to
use a stripped image like `gcr.io/distroless/base-debian11`, which does contain
up-to-date SSL libraries and supports dynamic libraries, but does not come with
a shell.
We also use `strip` where possible to strip symbols and debug info from binaries.
* Nuitka Python compiler creates dynamic executable with python packages as shared
libraries
* UPX creates a static executable, but after decompression it becomes a dynamic
executable
* cx_Freeze struggles with some `uvicorn` modules and doesn't copy all (system)
libs like `libreadline.so.1`, `libexpat.so.1` and `libz.so.1`. So we need to add
a routine to copy the libraries and set `LD_LIBRARY_PATH`
* PyInstaller seems to be able to copy all dependant shared libraries etc. Also
can use UPX when available. You might need to set `LD_LIBRARY_PATH`.

## Image sizes
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
Google distroless base Debian image.
