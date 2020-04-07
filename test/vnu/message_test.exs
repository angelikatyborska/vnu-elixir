defmodule Vnu.MessageTest do
  use ExUnit.Case
  alias Vnu.Message

  describe "from_html_response" do
    test "parses a map with camelCase string keys" do
      message =
        Message.from_http_response(%{
          "type" => "error",
          "subType" => "fatal",
          "message" => "some message",
          "extract" => "some extract",
          "offset" => 1,
          "firstLine" => 2,
          "firstColumn" => 3,
          "lastLine" => 4,
          "lastColumn" => 5,
          "hiliteStart" => 6,
          "hiliteLength" => 7
        })

      assert message.type == :error
      assert message.sub_type == :fatal
      assert message.message == "some message"
      assert message.extract == "some extract"
      assert message.offset == 1
      assert message.first_line == 2
      assert message.first_column == 3
      assert message.last_line == 4
      assert message.last_column == 5
      assert message.hilite_start == 6
      assert message.hilite_length == 7
    end

    test "values are nil if type does not match" do
      message =
        Message.from_http_response(%{
          "type" => "error",
          "subType" => "unknown",
          "message" => 1,
          "extract" => 2,
          "offset" => "1",
          "firstLine" => "2",
          "firstColumn" => "3",
          "lastLine" => "4",
          "lastColumn" => "5",
          "hiliteStart" => "6",
          "hiliteLength" => "7"
        })

      assert message.sub_type == nil
      assert message.message == nil
      assert message.extract == nil
      assert message.offset == nil
      assert message.first_line == nil
      assert message.first_column == nil
      assert message.last_line == nil
      assert message.last_column == nil
      assert message.hilite_start == nil
      assert message.hilite_length == nil
    end

    test "type is required, everything else optional" do
      assert Message.from_http_response(%{"type" => "error"}).type == :error
      assert Message.from_http_response(%{"type" => "info"}).type == :info

      assert Message.from_http_response(%{"type" => "non-document-error"}).type ==
               :non_document_error

      assert_raise CaseClauseError, fn ->
        Message.from_http_response(%{})
      end

      assert_raise CaseClauseError, fn ->
        Message.from_http_response(%{"type" => "unsupported type"})
      end
    end
  end
end
