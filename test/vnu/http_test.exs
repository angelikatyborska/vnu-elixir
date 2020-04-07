defmodule Vnu.HTTPTest do
  use ExUnit.Case
  alias Vnu.{HTTP, Config, Error, Response, Message}

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

      {:ok, %Response{}} =
        HTTP.get_response("", %Config{server_url: "http://localhost:#{bypass.port}"})
    end

    test "parses messages into structs", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        body = %{
          messages: [
            %{type: "error", message: "message 1"},
            %{
              type: "info",
              message: "message 2",
              subType: "warning",
              extract: "<span>\nHello World!\n</span>",
              firstLine: 1,
              lastLine: 2
            }
          ]
        }

        Plug.Conn.resp(conn, 200, Jason.encode!(body))
      end)

      {:ok, %Response{} = response} =
        HTTP.get_response("", %Config{server_url: "http://localhost:#{bypass.port}"})

      assert Enum.count(response.messages) == 2

      assert response.messages == [
               %Message{
                 type: :error,
                 message: "message 1"
               },
               %Message{
                 type: :info,
                 message: "message 2",
                 sub_type: :warning,
                 extract: "<span>\nHello World!\n</span>",
                 first_line: 1,
                 last_line: 2
               }
             ]
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
