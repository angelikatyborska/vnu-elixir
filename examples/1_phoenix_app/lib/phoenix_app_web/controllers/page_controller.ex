defmodule PhoenixAppWeb.PageController do
  use PhoenixAppWeb, :controller

  def home(conn, _params) do
    conn
    |> render(:home, layout: false)
  end

  def valid(conn, _params) do
    conn
    |> put_root_layout(html: false)
    |> render(:valid, layout: false)
  end

  def invalid(conn, _params) do
    conn
    |> put_root_layout(html: false)
    |> render(:invalid, layout: false)
  end
end
