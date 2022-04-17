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
libs like `libreadline.so.1`, `libexpat.so.1` and `libz.so.1`. This is why we
use a regular Debian as the base image instead of Google distroless.
* PyInstaller seems to be able to copy all dependant shared libraries etc. Also
can use UPX when available. You might need to set `LD_LIBRARY_PATH`.

## Image sizes
This is the output of `docker images` sorted by size:
```
REPOSITORY                        TAG             IMAGE ID       CREATED          SIZE
rest-app                          pyinstaller     2df87860d887   54 seconds ago   41.4MB
rest-app                          nuitka          81e534483a9a   23 hours ago     65.8MB
rest-app                          freeze          e2ef880418e0   23 hours ago     100MB
rest-app                          slim            cb9750b00759   23 hours ago     179MB
rest-app                          latest          db20cf008e29   23 hours ago     968MB
```
Note the difference between python-slim (`:slim`) images and regular python
images (`:latest`).
Also note that it is possible to create very compact images with `PyInstaller` and
Google distroless base Debian image.
