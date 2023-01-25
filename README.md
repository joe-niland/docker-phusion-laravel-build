# docker-phusion-laravel-build

Laravel CI environment based on the Phusion Ubuntu image.

## Variants

* $PHP_VERSION
  * PHP
  * Composer
  * NPM
  * Node-sass
  * awscli
  * sentry-cli
* $PHP_VERSION-docker
  * Above plus:
    * docker-cli
    * docker-compose
    * dockerd

## Building

`docker build -t joeniland/phusion-laravel-build .`

## Testing

### Shell

`docker run --rm -it --mount src=$(pwd),target=/app,type=bind --workdir /app joeniland/phusion-laravel-build:8.2-docker bash`

For use with docker:

`docker run --privileged --rm -it --mount src=$(pwd),target=/app,type=bind -v /var/run/docker.sock:/var/run/docker.sock -v /cache --workdir /app joeniland/phusion-laravel-build:8.2-docker docker run hello-world`

### Run unit tests

To run Unit tests with phpunit:

```shell
cd /dev/my-project
docker run -it --mount src=`pwd`,target=/app,type=bind joeniland/phusion-laravel-build:latest phpunit
```

... where `/dev/my-project` is your project root.
