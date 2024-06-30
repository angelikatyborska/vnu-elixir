# Vnu

![GitHub Workflow status](https://github.com/angelikatyborska/vnu-elixir/actions/workflows/test.yml/badge.svg)
![Hex.pm](https://img.shields.io/hexpm/v/vnu)
![Hex.pm](https://img.shields.io/hexpm/dt/vnu)
![Hex.pm](https://img.shields.io/hexpm/l/vnu)
[![Coverage Status](https://coveralls.io/repos/github/angelikatyborska/vnu-elixir/badge.svg?branch=master)](https://coveralls.io/github/angelikatyborska/vnu-elixir?branch=master)

An Elixir client for [the Nu HTML Checker (v.Nu)](https://validator.w3.org/nu/).

![Expected HTML document to be valid, but got 1 error. Attribute html-is-awesome not allowed on element body at this point.](https://raw.github.com/angelikatyborska/vnu-elixir/main/assets/overview.png)

[v.Nu](https://validator.w3.org/nu/) is a document validity checker used by the W3C.
It offers validating HTML, CSS, and SVG documents.

This library brings that functionality to Elixir by using the Checker's JSON API.
It offers ExUnit assertions for validating dynamic content in tests, Mix tasks for validating static content, and general purpose functions to fulfill other needs.

## Prerequisites

While it is possible to use this library with the service run by W3C at [validator.w3.org/nu](https://validator.w3.org/nu/),
I would recommend running your own instance. You will eliminate a lot of network latency if it runs on the same machine as your code, and you will not hit any rate limits that might exist for [validator.w3.org/nu](https://validator.w3.org/nu/).

The source of the Checker can be found in the repository [validator/validator](https://github.com/validator/validator).
Follow their instructions on how to download it and [run it as a web server](https://github.com/validator/validator#standalone-web-server).

The easiest option is to use the Docker image, like this:
```bash
docker run -d --rm -p 8888:8888 ghcr.io/validator/validator:latest
```

The command might require an additional `--platform linux/amd64` flag on M1 macs.

Check if the server is running:
```bash
$ curl localhost:8888 -I
HTTP/1.1 200 OK
```

## Installation

Make sure to read about the [prerequisites](#prerequisites) first.

Add Vnu as a dependency to your project's `mix.exs`. To use the built-in, Hackney-based HTTP client adapter, also add `:hackney`:

```elixir
defp deps do
  [
    {:vnu, "~> 1.1", only: [:dev, :test], runtime: false},
    {:hackney, "~> 1.18"}
  ]
end
```

Then run:

```bash
$ mix deps.get
```

If you don't want to use Hackney, you can implement your own HTTP client module using the [`Vnu.HTTPClient` behavior](lib/vnu/http_client.ex) and pass it in the `http_client` option.

## Documentation

[Available on hexdocs.pm](https://hexdocs.pm/vnu).

## Usage

See [the usage guide](guides/usage.md).

## Development

Make sure to read about the [prerequisites](#prerequisites) first.

After cloning the repository, run `mix deps.get` and you should be ready for development.

To ensure code consistency, run `mix lint`.

### Running tests

All test that expect to talk with the server accept the server's URL as an `VNU_SERVER_URL` environment variable or fallback to the default `http://localhost:8888`.

```bash
$ VNU_SERVER_URL=http://localhost:4000/ mix test 
```

If you're adding a new test, make sure it will do that do.

## Contributing

### Issues

If you noticed a problem with the library or its documentation, or have an idea for a feature, [open an issue](https://github.com/angelikatyborska/vnu-elixir/issues/new).

If you have an idea on how to act upon the problem or idea, feel free to open a pull request instead.

### Pull requests

If you noticed a problem with the library or its documentation and know how to fix it, or have an idea for a feature, or want to fix a typo, [open a pull request](https://github.com/angelikatyborska/vnu-elixir/pull/new/master).

If you are not sure of your changes or need help finishing them, open a pull request anyway. I'll try to help!

## License

Vnu is released under the MIT License. See the LICENSE file for further details.
