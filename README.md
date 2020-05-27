# docker-phusion-laravel-build

Laravel CI environment based on the Phusion Ubuntu image.

To build:
`docker build -t joeniland/phusion-laravel-build .`

Build a specific version:
`docker build -t joeniland/phusion-laravel-build:7.2 .`

To run Unit tests:

```shell
cd /dev/my-project
docker run -it --mount src=`pwd`,target=/app,type=bind joeniland/phusion-laravel-build:latest phpunit
```

or to interact with the project:

```shell
docker run -it --mount src=`pwd`,target=/app,type=bind joeniland/phusion-laravel-build:latest bash
```

, where `/dev/my-project` is your project root.

