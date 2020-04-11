defmodule PhoenixAppWeb.PageControllerTest do
  use PhoenixAppWeb.ConnCase

  test "GET /", %{conn: conn, vnu_opts: vnu_opts} do
    conn = get(conn, "/")

    html_response =
      conn
      |> html_response(200)
      |> assert_valid_html(
        Keyword.merge(vnu_opts,
          fail_on_warnings: false,
          filter: PhoenixAppWeb.VnuHTMLMessageFilter
        )
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
