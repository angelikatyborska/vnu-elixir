defmodule PhoenixAppWeb.PageControllerTest do
  use PhoenixAppWeb.ConnCase
  import Vnu.Assertions

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Phoenix!"
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

  test "GET /css/valid.css", %{conn: conn} do
    conn = get(conn, Routes.static_path(PhoenixAppWeb.Endpoint, "/css/valid.css"))

    conn
    |> response(200)
    |> assert_valid_css()
  end

  test "GET /css/invalid.css", %{conn: conn} do
    conn = get(conn, Routes.static_path(PhoenixAppWeb.Endpoint, "/css/invalid.css"))

    conn
    |> response(200)
    |> assert_valid_css()
  end
end
