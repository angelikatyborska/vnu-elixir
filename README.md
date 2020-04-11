# Vnu [WORK IN PROGRESS]

An Elixir client for [the Nu HTML Checker (v.Nu)](https://validator.w3.org/nu/).

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

Make sure to read about the [prerequisites](#prerequisites) first.

Add `:vnu` as a dependency to your project's `mix.exs`:

```elixir
defp deps do
  [
    {:vnu, github: "angelikatyborska/vnu-elixir", only: [:dev, :test], runtime: false}
  ]
end
```

(TODO: release to hex, add changelog)

And run:

```
$ mix deps.get
```

## Documentation

... (TODO: put hexdocs.pm link here)

## Usage

### ExUnit assertions

If you are building an application that generates HTML, CSS, or SVG files, you might want to use those validations in your tests.

- `Vnu.Assertions.assert_valid_html/2`
- `Vnu.Assertions.assert_valid_css/2`
- `Vnu.Assertions.assert_valid_svg/2`

#### Phoenix controller test example

```elixir
defmodule PhoenixAppWeb.PageControllerTest do
  use PhoenixAppWeb.ConnCase
  import Vnu.Assertions

    test "GET /", %{conn: conn} do
      vnu_opts = %{server_url: "http://localhost:8888", fail_on_warnings: true}
      conn = get(conn, "/")
      
      html_response =
        conn
        |> get("/")
        |> html_response(200)
        |> assert_valid_html(vnu_opts)
      
      assert html_response =~ "Welcome to Phoenix!"
    end
end
```

See [`examples/1_phoenix_app/test/phoenix_app_web/controllers/page_controller_test.exs`](https://github.com/angelikatyborska/vnu-elixir/blob/master/examples/1_phoenix_app/test/phoenix_app_web/controllers/page_controller_test.exs) for more.

![](examples/1_phoenix_app_failing_test.png)

### Mix task

If you have static HTML, CSS, or SVG files in your project, you might want to validate them with those mix tasks:

- `mix vnu.validate.html`
- `mix vnu.validate.css`
- `mix vnu.validate.svg`

#### Example

```bash
$ mix vnu.validate.css --server-url localhost:8888 assets/**/*.css
```

![](examples/1_phoenix_app_failing_mix_task.png)

### General purpose

If you need HTML, CSS, or SVG validation for something else, try one of those functions:

- `Vnu.validate_html/2`
- `Vnu.validate_css/2`
- `Vnu.validate_svg/2`

```elixir
iex> {:ok, result} = Vnu.validate_html("<!DOCTYPE html><html><head></head></html>", server_url: "http://localhost:8888")
{:ok,
 %Vnu.Result{
   messages: [
     %Vnu.Message{
       extract: "tml><head></head></html",
       first_column: 28,
       first_line: 1,
       hilite_length: 7,
       hilite_start: 10,
       last_column: 34,
       last_line: 1,
       message: "Element “head” is missing a required instance of child element “title”.",
       offset: nil,
       sub_type: nil,
       type: :error
     },
     %Vnu.Message{
       extract: "TYPE html><html><head>",
       first_column: 16,
       first_line: 1,
       hilite_length: 6,
       hilite_start: 10,
       last_column: 21,
       last_line: 1,
       message: "Consider adding a “lang” attribute to the “html” start tag to declare the language of this document.",
       offset: nil,
       sub_type: :warning,
       type: :info
     }
   ]
 }}

iex> Vnu.valid?(result)
false
```

## Contributing

... (TODO: describe)

### Running tests

... (TODO: describe)

## License

Vnu is released under the MIT License. See the LICENSE file for further details.
