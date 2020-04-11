defmodule Mix.Tasks.Vnu.Validate.CssTest do
  use ExUnit.Case

  test "happy path" do
    assert catch_exit(Mix.Tasks.Vnu.Validate.Css.run(["test/fixtures/valid.css"])) ==
             {:shutdown, 0}

    assert catch_exit(Mix.Tasks.Vnu.Validate.Css.run(["test/fixtures/invalid.css"])) ==
             {:shutdown, 1}

    assert catch_exit(
             Mix.Tasks.Vnu.Validate.Css.run([
               "test/fixtures/valid.css",
               "test/fixtures/invalid.css"
             ])
           ) == {:shutdown, 1}
  end

  test "file must exist" do
    assert_raise Mix.Error, "File banana could not be read:\n  :enoent", fn ->
      Mix.Tasks.Vnu.Validate.Css.run(["banana"])
    end
  end

  test "requires some files" do
    assert_raise Mix.Error, "No files given", fn ->
      Mix.Tasks.Vnu.Validate.Css.run([])
    end

    usage_info = usage_info()
    assert_received {:mix_shell, :info, ^usage_info}
  end

  test "requires valid options" do
    assert_raise Mix.Error, "Invalid options: [{\"--banana\", nil}]", fn ->
      Mix.Tasks.Vnu.Validate.Css.run(["--banana"])
    end

    usage_info = usage_info()
    assert_received {:mix_shell, :info, ^usage_info}
  end

  defp usage_info() do
    [
      """
      mix vnu.validate.css [options] file1 [file2, file3...]

      Options:
        --server-url [string]
        --fail-on-warnings / --no-fail-on-warnings

      Example:
        mix vnu.validate.css --server-url localhost:8888 priv/static/**/*.css
      """
    ]
  end
end
