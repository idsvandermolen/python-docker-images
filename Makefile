.PHONY: help clean image shell serve image-slim shell-slim serve-slim nuitka-image \
	nuitka-shell nuitka-serve freeze-image freeze-shell freeze-serve \
	pyinstaller-image pyinstaller-shell pyinstaller-serve

IMAGE := rest-app

help:  ## Show help messages for make targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

all: image image-slim nuitka-image freeze-image pyinstaller-image ## Build all images

clean:
	@find app -name __pycache__ -type d -depth -exec rm -rf {} ';'

image: clean ## Build regular docker image
	@docker build -f Dockerfile -t $(IMAGE) .

shell: image ## Start regular docker container shell
	@docker run -it --rm --entrypoint /bin/bash $(IMAGE)

serve: image ## Start regular server
	@docker run -it --rm -p 80:80 $(IMAGE)

image-slim: clean ## Build slim docker image
	@docker build -f Dockerfile.slim -t $(IMAGE):slim .

shell-slim: image-slim ## Start slim docker container shell
	@docker run -it --rm --entrypoint /bin/bash $(IMAGE):slim

serve-slim: image-slim ## Start slim server
	@docker run -it --rm -p 80:80 $(IMAGE):slim

nuitka-image: clean ## Build Nuitka docker image
	@docker build -f Dockerfile.nuitka -t $(IMAGE):nuitka .

nuitka-shell: nuitka-image ## Start Nuitka docker container shell
	@docker run -it --rm --entrypoint /bin/bash $(IMAGE):nuitka

nuitka-dev: nuitka-image ## Start Nuitka server
	@docker run -it --rm -p 80:80 $(IMAGE):nuitka

freeze-image: clean ## Build cx_Freeze docker image
	@docker build -f Dockerfile.freeze -t $(IMAGE):freeze .

freeze-shell: freeze-image ## Start cx_Freeze docker container shell
	@docker run -it --rm --entrypoint /bin/bash $(IMAGE):freeze

freeze-dev: freeze-image ## Start cx_Freeze server
	@docker run -it --rm -p 80:80 $(IMAGE):freeze

pyinstaller-image: clean ## Build PyInstaller docker image
	@docker build -f Dockerfile.pyinstaller -t $(IMAGE):pyinstaller .

pyinstaller-shell: pyinstaller-image ## Start PyInstaller docker container shell
	@docker run -it --rm --entrypoint /bin/bash $(IMAGE):pyinstaller

pyinstaller-dev: pyinstaller-image ## Start PyInstaller server
	@docker run -it --rm -p 80:80 $(IMAGE):pyinstaller
