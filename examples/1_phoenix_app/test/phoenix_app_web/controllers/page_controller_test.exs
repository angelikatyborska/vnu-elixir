defmodule PhoenixAppWeb.PageControllerTest do
  use PhoenixAppWeb.ConnCase
  import Vnu.Assertions

  defmodule ExampleVnuMessageFilter do
    @behaviour Vnu.MessageFilter

    @impl Vnu.MessageFilter
    def exclude_message?(%Vnu.Message{message: message}) do
      # Those errors are caused by the CSRF meta tag (`csrf_meta_tag()`) present in the layout
      patterns_to_ignore = [
        ~r/A document must not include more than one “meta” element with a “charset” attribute./,
        ~r/Attribute “(.)*” not allowed on element “meta” at this point./
      ]

      Enum.any?(patterns_to_ignore, &Regex.match?(&1, message))
    end
  end

  test "GET /", %{conn: conn, vnu_opts: vnu_opts} do
    conn = get(conn, "/")

    html_response =
      conn
      |> html_response(200)
      |> assert_valid_html(
        Keyword.merge(vnu_opts, fail_on_warnings: false, filter: ExampleVnuMessageFilter)
      )

    assert html_response =~ "Welcome to Phoenix!"
  end

  test "GET /valid", %{conn: conn, vnu_opts: vnu_opts} do
    conn = get(conn, "/valid")

    conn
    |> html_response(200)
    |> assert_valid_html(vnu_opts)
  end

  test "GET /invalid", %{conn: conn, vnu_opts: vnu_opts} do
    conn = get(conn, "/invalid")

    conn
    |> html_response(200)
    |> assert_valid_html(vnu_opts)
  end
end
