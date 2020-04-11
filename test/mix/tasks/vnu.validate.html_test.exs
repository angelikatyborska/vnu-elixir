defmodule Mix.Tasks.Vnu.Validate.HtmlTest do
  use ExUnit.Case, async: false

  test "happy path" do
    assert catch_exit(Mix.Tasks.Vnu.Validate.Html.run(["test/fixtures/valid.html"])) ==
             {:shutdown, 0}

    assert catch_exit(Mix.Tasks.Vnu.Validate.Html.run(["test/fixtures/warning.html"])) ==
             {:shutdown, 0}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run(["test/fixtures/warning.html", "--fail-on-warnings"])
           ) == {:shutdown, 1}

    assert catch_exit(Mix.Tasks.Vnu.Validate.Html.run(["test/fixtures/invalid.html"])) ==
             {:shutdown, 1}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
               "test/fixtures/valid.html",
               "test/fixtures/invalid.html"
             ])
           ) == {:shutdown, 1}
  end

  test "with a filter" do
    assert catch_exit(Mix.Tasks.Vnu.Validate.Html.run(["test/fixtures/invalid.html"])) ==
             {:shutdown, 1}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Html.run([
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
    assert_raise Mix.Error, "No files given", fn ->
      Mix.Tasks.Vnu.Validate.Html.run([])
    end

    usage_info = Vnu.CLI.usage_info(:html)
    assert_received {:mix_shell, :info, [^usage_info]}
  end

  test "requires valid options" do
    assert_raise Mix.Error, "Invalid options: [{\"--banana\", nil}]", fn ->
      Mix.Tasks.Vnu.Validate.Html.run(["--banana"])
    end

    usage_info = Vnu.CLI.usage_info(:html)
    assert_received {:mix_shell, :info, [^usage_info]}
  end
end
