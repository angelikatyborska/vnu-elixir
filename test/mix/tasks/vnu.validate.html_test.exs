defmodule Mix.Tasks.Vnu.Validate.HtmlTest do
  use Vnu.ServerCase
  import ExUnit.CaptureIO

  test "happy path", %{opts: opts} do
    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "test/fixtures/valid.html"
             ])
           ) ==
             {:shutdown, 0}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "test/fixtures/warning.html"
             ])
           ) ==
             {:shutdown, 0}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "test/fixtures/warning.html",
               "--fail-on-warnings"
             ])
           ) == {:shutdown, 1}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "test/fixtures/invalid.html"
             ])
           ) ==
             {:shutdown, 1}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "test/fixtures/valid.html",
               "test/fixtures/invalid.html"
             ])
           ) == {:shutdown, 1}
  end

  test "with a filter", %{opts: opts} do
    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "test/fixtures/invalid.html"
             ])
           ) ==
             {:shutdown, 1}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
               "--server-url",
               Keyword.get(opts, :server_url),
               "--filter",
               "Vnu.ExcludeAllMessageFilter",
               "test/fixtures/invalid.html"
             ])
           ) == {:shutdown, 0}
  end

  test "file must exist" do
    assert_raise Mix.Error, "File banana could not be read:\n  :enoent", fn ->
      Mix.Tasks.Vnu.Validate.Html.run(["banana"])
    end
  end

  test "requires some files" do
    assert capture_io(fn ->
             assert_raise Mix.Error, "No files given", fn ->
               Mix.Tasks.Vnu.Validate.Html.run([])
             end
           end) == capture_io(fn -> Mix.Tasks.Help.run(["vnu.validate.html"]) end)
  end

  test "requires valid options" do
    assert capture_io(fn ->
             assert_raise Mix.Error, "Invalid options: [{\"--banana\", nil}]", fn ->
               Mix.Tasks.Vnu.Validate.Html.run(["--banana"])
             end
           end) == capture_io(fn -> Mix.Tasks.Help.run(["vnu.validate.html"]) end)
  end
end
