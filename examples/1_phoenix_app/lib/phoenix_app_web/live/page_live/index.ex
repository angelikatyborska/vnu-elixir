defmodule PhoenixAppWeb.PageLive.Index do
  use PhoenixAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, :star_treks, [
       %{id: "ds9", title: "Star Trek: Deep Space Nine"},
       %{id: "tng", title: "Star Trek: The Next Generation"},
       %{id: "snw", title: "Star Trek: Strange New Worlds"},
       %{id: "voy", title: "Star Trek: Voyager"},
       %{id: "ent", title: "Star Trek: Enterprise"},
       %{id: "tos", title: "Star Trek: The Original Series"},
       %{id: "orv", title: "The Orville"},
       %{id: "dis", title: "Star Trek: Discovery"},
       %{id: "pic", title: "Star Trek: Picard"}
     ]), layout: false}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :valid, _params) do
    socket
    |> assign(:page_title, "Valid HTML")
  end

  defp apply_action(socket, :invalid, _params) do
    socket
    |> assign(:page_title, "Invalid HTML")
  end
end
