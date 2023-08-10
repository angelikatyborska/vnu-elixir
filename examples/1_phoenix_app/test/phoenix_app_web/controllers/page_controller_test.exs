defmodule PhoenixAppWeb.PageControllerTest do
  use PhoenixAppWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")

    html_response =
      conn
      |> html_response(200)
      |> assert_valid_html(
        fail_on_warnings: false,
        filter: PhoenixAppWeb.VnuHTMLMessageFilter
      )

    assert html_response =~ "Peace of mind from prototype to production"
  end

  test "GET /valid", %{conn: conn} do
    conn = get(conn, "/valid")

    conn
    |> html_response(200)
    |> assert_valid_html()
  end

  test "GET /invalid", %{conn: conn} do
    conn = get(conn, "/invalid")

    conn
    |> html_response(200)
    |> assert_valid_html()
  end
end
