defmodule Mix.Tasks.VnuTest do
  use ExUnit.Case

  test "provides a list of available vnu mix tasks" do
    :ok = Mix.Tasks.Vnu.run([])
    assert_received {:mix_shell, :info, ["Vnu v" <> _]}
    assert_received {:mix_shell, :info, ["mix vnu.validate.html" <> _]}
    assert_received {:mix_shell, :info, ["mix vnu.validate.css" <> _]}
    assert_received {:mix_shell, :info, ["mix vnu.validate.svg" <> _]}
  end

  test "expects no arguments" do
    assert_raise Mix.Error, fn ->
      Mix.Tasks.Vnu.run(["invalid"])
    end
  end
end
