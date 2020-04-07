defmodule Vnu.HTTPTest do
  use ExUnit.Case
  alias Vnu.{HTTP, Config, Error}

  describe "get_response" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "does a request", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)
        assert Plug.Conn.get_req_header(conn, "content-type") == ["text/html"]
        assert conn.query_params == %{"out" => "json"}
        Plug.Conn.resp(conn, 200, "{}")
      end)

      {:ok, response} =
        HTTP.get_response("", %Config{server_url: "http://localhost:#{bypass.port}"})

      assert response
    end

    test "can handle non-JSON body", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 200, "ok")
      end)

      {:error, %Error{} = error} =
        HTTP.get_response("", %Config{server_url: "http://localhost:#{bypass.port}"})

      assert error.reason == :unexpected_server_response
    end

    test "can handle non-200 status code", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 500, "")
      end)

      {:error, %Error{} = error} =
        HTTP.get_response("", %Config{server_url: "http://localhost:#{bypass.port}"})

      assert error.reason == :unexpected_server_response
    end
  end
end
