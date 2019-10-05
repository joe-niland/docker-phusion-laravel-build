# docker-phusion-laravel-build

Laravel CI environment based on the Phusion Ubuntu image.

To build:
docker build -t joeniland/phusion-laravel-build .

To run Unit tests:
docker run -it --volume=/dev/my-project:/app --workdir="/app" joeniland/phusion-laravel-build phpunit

Where volume = project root

PHPunit is run automatically and output should be:

PHPUnit 5.7.21 by Sebastian Bergmann and contributors.

.......                                                             7 / 7 (100%)

Time: 4.56 seconds, Memory: 78.00MB

OK (7 tests, 12 assertions)

