defmodule Vnu.ValidatorTest do
  use ExUnit.Case
  alias Vnu.{Validator, Error, Response}

  describe "validate" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "returns the messages", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        body = %{
          messages: [
            %{type: "info", subType: "warning", message: "message 1"},
            %{type: "error", subType: "fatal", message: "message 2"}
          ]
        }

        Plug.Conn.resp(conn, 200, Jason.encode!(body))
      end)

      {:ok, %Response{messages: [message1, message2]}} =
        Validator.validate("", server_url: "http://localhost:#{bypass.port}")

      assert message1.type == :info
      assert message1.sub_type == :warning
      assert message2.type == :error
      assert message2.sub_type == :fatal
    end

    test "returns an error if there were non-document errors", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        body = %{
          messages: [
            %{type: "non-document-error", message: "message 1"}
          ]
        }

        Plug.Conn.resp(conn, 200, Jason.encode!(body))
      end)

      {:error, %Error{} = error} =
        Validator.validate("", server_url: "http://localhost:#{bypass.port}")

      assert error.reason == :unexpected_server_response

      assert error.message ==
               "The server could not finish validating the document, non-document errors occurred: [%Vnu.Message{extract: nil, first_column: nil, first_line: nil, hilite_length: nil, hilite_start: nil, last_column: nil, last_line: nil, message: \"message 1\", offset: nil, sub_type: nil, type: :non_document_error}]"
    end
  end
end
