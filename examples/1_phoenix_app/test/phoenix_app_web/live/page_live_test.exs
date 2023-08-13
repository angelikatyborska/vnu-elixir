defmodule PhoenixAppWeb.PageLiveTest do
  use PhoenixAppWeb.ConnCase

  import Phoenix.LiveViewTest

  test "/valid disconnected and connected mount", %{conn: conn} do
    conn = get(conn, ~p"/live/valid")

    conn
    |> html_response(200)
    |> assert_valid_html()

    {:ok, _index_live, html} = live(conn)

    assert_valid_html_without_doctype(html)
  end

  test "/invalid disconnected and connected mount", %{conn: conn} do
    conn = get(conn, ~p"/live/invalid")

    conn
    |> html_response(200)
    |> assert_valid_html()

    {:ok, index_live, html} = live(conn)

    assert_valid_html_without_doctype(html)

    # assert index_live |> element("#link-invalid") |> render_click()
    # at the moment, there's no public API to give us the full page HTML after the update
  end
end
