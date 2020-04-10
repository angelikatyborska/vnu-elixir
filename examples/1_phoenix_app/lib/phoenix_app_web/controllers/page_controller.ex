defmodule PhoenixAppWeb.PageController do
  use PhoenixAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def valid(conn, _params) do
    conn
    |> put_layout(false)
    |> render("valid.html")
  end

  def invalid(conn, _params) do
    conn
    |> put_layout(false)
    |> render("invalid.html")
  end
end
