defmodule Mix.Tasks.Vnu.Validate.SvgTest do
  use ExUnit.Case

  test "happy path" do
    assert catch_exit(Mix.Tasks.Vnu.Validate.Svg.run(["test/fixtures/valid.svg"])) ==
             {:shutdown, 0}

    assert catch_exit(Mix.Tasks.Vnu.Validate.Svg.run(["test/fixtures/invalid.svg"])) ==
             {:shutdown, 1}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Svg.run([
               "test/fixtures/valid.svg",
               "test/fixtures/invalid.svg"
             ])
           ) == {:shutdown, 1}
  end

  test "file must exist" do
    assert_raise Mix.Error, "File banana could not be read:\n  :enoent", fn ->
      Mix.Tasks.Vnu.Validate.Svg.run(["banana"])
    end
  end

  test "requires some files" do
    assert_raise Mix.Error, "No files given", fn ->
      Mix.Tasks.Vnu.Validate.Svg.run([])
    end

    usage_info = Vnu.CLI.usage_info(:svg)
    assert_received {:mix_shell, :info, [^usage_info]}
  end

  test "requires valid options" do
    assert_raise Mix.Error, "Invalid options: [{\"--banana\", nil}]", fn ->
      Mix.Tasks.Vnu.Validate.Svg.run(["--banana"])
    end

    usage_info = Vnu.CLI.usage_info(:svg)
    assert_received {:mix_shell, :info, [^usage_info]}
  end
end
