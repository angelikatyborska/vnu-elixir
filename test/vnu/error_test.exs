defmodule Vnu.ErrorTest do
  use ExUnit.Case
  alias Vnu.Error

  describe "new" do
    test "expects a known reason" do
      assert Error.new(:unexpected_server_response, "")
      assert Error.new(:invalid_config, "")

      assert_raise FunctionClauseError, fn ->
        Error.new(:unexpected_romulan_attack, "")
      end

      assert_raise FunctionClauseError, fn ->
        Error.new(123, "")
      end
    end

    test "message must be a string" do
      assert Error.new(:unexpected_server_response, "")

      assert_raise FunctionClauseError, fn ->
        Error.new(:unexpected_server_response, 123)
      end
    end
  end
end
