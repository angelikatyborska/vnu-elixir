defmodule Vnu.ServerCase do
  use ExUnit.CaseTemplate

  setup _tags do
    {:ok, %{opts: [server_url: System.get_env("VNU_SERVER_URL") || "http://localhost:8888"]}}
  end
end
