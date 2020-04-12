defmodule Mix.Tasks.Vnu.Validate.SvgTest do
  use Vnu.ServerCase
  import ExUnit.CaptureIO

  test "happy path", %{opts: opts} do
    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Svg.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "test/fixtures/valid.svg"
             ])
           ) ==
             {:shutdown, 0}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Svg.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "test/fixtures/invalid.svg"
             ])
           ) ==
             {:shutdown, 1}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Svg.run([
               "--server-url",
               Keyword.get(opts, :server_url),
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
    assert capture_io(fn ->
             assert_raise Mix.Error, "No files given", fn ->
               Mix.Tasks.Vnu.Validate.Svg.run([])
             end
           end) == capture_io(fn -> Mix.Tasks.Help.run(["vnu.validate.svg"]) end)
  end

  test "requires valid options" do
    assert capture_io(fn ->
             assert_raise Mix.Error, "Invalid options: [{\"--banana\", nil}]", fn ->
               Mix.Tasks.Vnu.Validate.Svg.run(["--banana"])
             end
           end) == capture_io(fn -> Mix.Tasks.Help.run(["vnu.validate.svg"]) end)
  end
end
