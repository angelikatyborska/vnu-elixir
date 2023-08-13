# Usage

There are 3 different ways of using this library:
- [ExUnit assertions](#exunit-assertions),
- [mix tasks for your static assets](#mix-tasks),
- or [generic function calls for all other needs](#other-needs).

## ExUnit assertions

If you are building an application that generates HTML, CSS, or SVG files, you might want to use those validations in your tests.

- `Vnu.Assertions.assert_valid_html/2`
- `Vnu.Assertions.assert_valid_css/2`
- `Vnu.Assertions.assert_valid_svg/2`

### Phoenix example

I would recommend defining a local `assert_valid_html` function in your [`ConnCase`](https://hexdocs.pm/phoenix/testing.html#the-conncase) to have a single place to pass your default options.

```elixir
defmodule PhoenixAppWeb.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      # ...
      def assert_valid_html(html, vnu_opts \\ []) do
        default_vnu_opts = [
          server_url: "http://localhost:8888/",
          filter: PhoenixAppWeb.VnuHTMLMessageFilter,
          fail_on_warnings: true
        ]

        Vnu.Assertions.assert_valid_html(html, Keyword.merge(default_vnu_opts, vnu_opts))
      end
    end
  end
end
```

Then, you can use this function in your controller tests, LiveView tests, and integration tests.

#### Controller tests

```elixir
defmodule PhoenixAppWeb.PageControllerTest do
  use PhoenixAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    html_response =
      conn
      |> html_response(200)
      |> assert_valid_html(fail_on_warnings: false)

    assert html_response =~ "Peace of mind from prototype to production"
  end
end
```

![](https://raw.github.com/angelikatyborska/vnu-elixir/main/assets/controller_test.png)


#### LiveView tests

TODO: add to example phoenix app and describe

#### Hound integration tests

TODO: add to example phoenix app and describe

## Mix tasks

If you have static HTML, CSS, or SVG files in your project, you might want to validate them with those mix tasks:

- `mix vnu.validate.html`
- `mix vnu.validate.css`
- `mix vnu.validate.svg`

### Example

```bash
$ mix vnu.validate.css --server-url http://localhost:8888 assets/**/*.css
```

![](https://raw.github.com/angelikatyborska/vnu-elixir/main/assets/mix_task.png)

## Other needs

If you need HTML, CSS, or SVG validation for something else, try one of those functions:

- `Vnu.validate_html/2`
- `Vnu.validate_css/2`
- `Vnu.validate_svg/2`

### Example

```elixir
iex> {:ok, result} = Vnu.validate_html("<!DOCTYPE html><html><head></head></html>",
  server_url: "http://localhost:8888")
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
