# Installation

## Prerequisites

While it is possible to use this library with the service run by W3C at [validator.w3.org/nu](https://validator.w3.org/nu/),
I would recommend running your own instance. You will eliminate a lot of network latency if it runs on the same machine as your code, and you will not hit any rate limits that might exist for [validator.w3.org/nu](https://validator.w3.org/nu/).

The source of the Checker can be found in the repository [validator/validator](https://github.com/validator/validator).
Follow their instructions on how to download it and [run it as a web server](https://github.com/validator/validator#standalone-web-server).

The easiest option is to use the Docker image, like this:
```bash
docker run -it --rm -p 8888:8888 ghcr.io/validator/validator:latest
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
    {:hackney, "~> 1.17"}
  ]
end
```

And run:

```bash
$ mix deps.get
```

If you don't want to use Hackney, you can implement your own HTTP client module using the `Vnu.HTTPClient` behavior and pass it in the `http_client` option.
