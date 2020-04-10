# Vnu

An Elixir client for [the Nu HTML Checker (v.Nu)](https://validator.w3.org/nu/) HTML validator.

## Prerequisites

You will need your own copy of the Nu HTML Checker.
The source of the Checker can be found in the repository [validator/validator](https://github.com/validator/validator).
Follow their instructions on how to download it and [run it as a web server](https://github.com/validator/validator#standalone-web-server).

The easiest option is to use the Docker image, like this:
```bash
docker run -it --rm -p 8888:8888 validator/validator:latest
```

Check if the server is running:
```bash
$ curl localhost:8888 -I
HTTP/1.1 200 OK
```

## Installation

...

## Usage

### As ExUnit assertions

...

### As a mix task

...

### General usage

...

## Contributing

...

## License

Vnu is released under the MIT License. See the LICENSE file for further details.
