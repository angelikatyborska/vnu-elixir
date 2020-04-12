defmodule Vnu.HTTPTest do
  use ExUnit.Case
  alias Vnu.{HTTP, Config, Error, Result, Message}

  describe "get_result" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "does a request", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        conn = Plug.Conn.fetch_query_params(conn)
        assert Plug.Conn.get_req_header(conn, "content-type") == ["text/html; charset=utf-8"]
        assert conn.query_params == %{"out" => "json"}
        Plug.Conn.resp(conn, 200, "{}")
      end)

      {:ok, %Result{}} =
        HTTP.get_result("", Config.new!(server_url: "http://localhost:#{bypass.port}"))
    end

    test "sets content-type for css", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        assert Plug.Conn.get_req_header(conn, "content-type") == ["text/css; charset=utf-8"]
        Plug.Conn.resp(conn, 200, "{}")
      end)

      {:ok, %Result{}} =
        HTTP.get_result(
          "",
          Config.new!(server_url: "http://localhost:#{bypass.port}", format: :css)
        )
    end

    test "sets content-type for svg", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        assert Plug.Conn.get_req_header(conn, "content-type") == ["image/svg+xml; charset=utf-8"]
        Plug.Conn.resp(conn, 200, "{}")
      end)

      {:ok, %Result{}} =
        HTTP.get_result(
          "",
          Config.new!(server_url: "http://localhost:#{bypass.port}", format: :svg)
        )
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

      {:ok, %Result{} = response} =
        HTTP.get_result("", Config.new!(server_url: "http://localhost:#{bypass.port}"))

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
        HTTP.get_result("", Config.new!(server_url: "http://localhost:#{bypass.port}"))

      assert error.reason == :unexpected_server_response
    end

    test "can handle non-200 status code", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        Plug.Conn.resp(conn, 500, "")
      end)

      {:error, %Error{} = error} =
        HTTP.get_result("", Config.new!(server_url: "http://localhost:#{bypass.port}"))

      assert error.reason == :unexpected_server_response
    end

    test "works against the real server" do
      {:ok, %Result{}} =
        HTTP.get_result(
          "",
          Config.new!(server_url: "http://validator.w3.org/nu", format: :html)
        )

      {:ok, %Result{}} =
        HTTP.get_result(
          "",
          Config.new!(server_url: "https://validator.w3.org/nu", format: :html)
        )
    end
  end
end
