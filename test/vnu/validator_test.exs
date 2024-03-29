defmodule Vnu.ValidatorTest do
  use ExUnit.Case
  alias Vnu.{Validator, Error, Result, Message}

  describe "valid?" do
    test "only messages of type info are expected" do
      assert Validator.valid?(%Result{messages: []})
      assert Validator.valid?(%Result{messages: [%Message{type: :info}]})

      assert Validator.valid?(%Result{
               messages: [%Message{type: :info}, %Message{type: :info, sub_type: :warning}]
             })

      refute Validator.valid?(%Result{
               messages: [%Message{type: :error}]
             })

      refute Validator.valid?(%Result{
               messages: [%Message{type: :unknown_type}]
             })

      refute Validator.valid?(%Result{
               messages: [%Message{type: :info}, %Message{type: :error}]
             })
    end

    test "can treat warnings as errors" do
      assert Validator.valid?(%Result{messages: []}, fail_on_warnings: true)

      assert Validator.valid?(%Result{messages: [%Message{type: :info}]}, fail_on_warnings: true)

      refute Validator.valid?(
               %Result{
                 messages: [%Message{type: :info}, %Message{type: :info, sub_type: :warning}]
               },
               fail_on_warnings: true
             )

      refute Validator.valid?(
               %Result{
                 messages: [%Message{type: :error}]
               },
               fail_on_warnings: true
             )

      refute Validator.valid?(
               %Result{
                 messages: [%Message{type: :unknown_type}]
               },
               fail_on_warnings: true
             )

      refute Validator.valid?(
               %Result{
                 messages: [%Message{type: :info}, %Message{type: :error}]
               },
               fail_on_warnings: true
             )
    end
  end

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

      {:ok, %Result{messages: [message1, message2]}} =
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

      expected_error_struct = %Vnu.Message{
        extract: nil,
        first_column: nil,
        first_line: nil,
        hilite_length: nil,
        hilite_start: nil,
        last_column: nil,
        last_line: nil,
        message: "message 1",
        offset: nil,
        sub_type: nil,
        type: :non_document_error
      }

      assert error.message ==
               "The server could not finish validating the document, non-document errors occurred: [#{inspect(expected_error_struct)}]"
    end

    test "filters out the messages", %{bypass: bypass} do
      defmodule Filter do
        @behaviour Vnu.MessageFilter

        @impl Vnu.MessageFilter
        def exclude_message?(message) do
          message.type == :error
        end
      end

      Bypass.expect(bypass, fn conn ->
        body = %{
          messages: [
            %{type: "info", subType: "warning", message: "message 1"},
            %{type: "error", subType: "fatal", message: "message 2"}
          ]
        }

        Plug.Conn.resp(conn, 200, Jason.encode!(body))
      end)

      {:ok, %Result{messages: [message1]}} =
        Validator.validate("", server_url: "http://localhost:#{bypass.port}", filter: Filter)

      assert message1.type == :info
      assert message1.sub_type == :warning
    end
  end

  describe "validate!" do
    setup do
      bypass = Bypass.open()
      {:ok, bypass: bypass}
    end

    test "returns the result", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        body = %{
          messages: [
            %{type: "info", subType: "warning", message: "message 1"},
            %{type: "error", subType: "fatal", message: "message 2"}
          ]
        }

        Plug.Conn.resp(conn, 200, Jason.encode!(body))
      end)

      %Result{messages: [_, _]} =
        Validator.validate!("", server_url: "http://localhost:#{bypass.port}")
    end

    test "raises", %{bypass: bypass} do
      Bypass.expect(bypass, fn conn ->
        body = %{
          messages: [
            %{type: "non-document-error", message: "message 1"}
          ]
        }

        Plug.Conn.resp(conn, 200, Jason.encode!(body))
      end)

      expected_error_struct = %Vnu.Message{
        extract: nil,
        first_column: nil,
        first_line: nil,
        hilite_length: nil,
        hilite_start: nil,
        last_column: nil,
        last_line: nil,
        message: "message 1",
        offset: nil,
        sub_type: nil,
        type: :non_document_error
      }

      assert_raise Error,
                   "The server could not finish validating the document, non-document errors occurred: [#{inspect(expected_error_struct)}]",
                   fn ->
                     Validator.validate!("", server_url: "http://localhost:#{bypass.port}")
                   end
    end
  end
end
