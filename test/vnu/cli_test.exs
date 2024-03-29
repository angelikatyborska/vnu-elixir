defmodule Vnu.CLITest do
  use Vnu.ServerCase
  import Vnu.Formatter, only: [with_color: 2, success_color: 0]
  alias Vnu.{Result, CLI, Formatter}

  describe "validate html" do
    test "no errors", %{opts: opts} do
      assert catch_exit(
               CLI.validate(
                 [
                   "--server-url",
                   Keyword.get(opts, :server_url),
                   "test/fixtures/valid.html"
                 ],
                 :html
               )
             ) == {:shutdown, 0}

      assert_received {:mix_shell, :info, ["\nValidating HTML files:"]}
      assert_received {:mix_shell, :info, ["  - test/fixtures/valid.html\n"]}
      summary = [with_color("✓ All OK!", success_color())]
      assert_received {:mix_shell, :info, ^summary}
    end

    test "only warnings", %{opts: opts} do
      path = "test/fixtures/warning.html"
      {:ok, %Result{messages: [warning]}} = Vnu.validate_html(File.read!(path), opts)
      [warning] = Formatter.format_messages([warning], path)
      warning = [warning <> "\n"]

      assert catch_exit(
               CLI.validate(
                 ["--server-url", Keyword.get(opts, :server_url), path],
                 :html
               )
             ) == {:shutdown, 0}

      assert_received {:mix_shell, :info, ["\nValidating HTML files:"]}
      assert_received {:mix_shell, :info, ["  - test/fixtures/warning.html\n"]}

      assert_received {:mix_shell, :info, ^warning}

      summary = [with_color("✓ All OK!", success_color())]
      assert_received {:mix_shell, :info, ^summary}
    end

    test "only warnings, but fail on warnings", %{opts: opts} do
      path = "test/fixtures/warning.html"
      {:ok, %Result{messages: [warning]}} = Vnu.validate_html(File.read!(path), opts)
      [warning] = Formatter.format_messages([warning], path)
      warning = [warning <> "\n"]

      assert catch_exit(
               CLI.validate(
                 ["--server-url", Keyword.get(opts, :server_url), "--fail-on-warnings", path],
                 :html
               )
             ) == {:shutdown, 1}

      assert_received {:mix_shell, :info, ["\nValidating HTML files:"]}
      assert_received {:mix_shell, :info, ["  - test/fixtures/warning.html\n"]}

      assert_received {:mix_shell, :info, ^warning}

      summary =
        path <>
          ": " <>
          Formatter.format_counts(%{error_count: 0, warning_count: 1, info_count: 0},
            exclude_zeros: true,
            exclude_infos: true
          )

      summary = ["Summary:\n  - " <> summary]

      assert_received {:mix_shell, :info, ^summary}
    end

    test "many files, many errors", %{opts: opts} do
      path1 = "test/fixtures/valid.html"
      path2 = "test/fixtures/warning.html"
      path3 = "test/fixtures/invalid.html"
      {:ok, %Result{messages: messages2}} = Vnu.validate_html(File.read!(path2), opts)
      {:ok, %Result{messages: messages3}} = Vnu.validate_html(File.read!(path3), opts)
      messages2 = (Formatter.format_messages(messages2, path2) |> Enum.join("\n\n")) <> "\n"
      messages3 = (Formatter.format_messages(messages3, path3) |> Enum.join("\n\n")) <> "\n"

      assert catch_exit(
               CLI.validate(
                 ["--server-url", Keyword.get(opts, :server_url), path1, path2, path3],
                 :html
               )
             ) == {:shutdown, 1}

      assert_received {:mix_shell, :info, ["\nValidating HTML files:"]}

      assert_received {:mix_shell, :info,
                       [
                         "  - test/fixtures/valid.html\n  - test/fixtures/warning.html\n  - test/fixtures/invalid.html\n"
                       ]}

      assert_received {:mix_shell, :info, [^messages2]}
      assert_received {:mix_shell, :info, [^messages3]}

      summary1 = path1 <> ": " <> with_color("✓ OK", success_color())

      summary2 =
        path2 <>
          ": " <>
          Formatter.format_counts(%{error_count: 0, warning_count: 1, info_count: 0},
            exclude_zeros: true,
            exclude_infos: true
          )

      summary3 =
        path3 <>
          ": " <>
          Formatter.format_counts(%{error_count: 2, warning_count: 1, info_count: 0},
            exclude_zeros: true,
            exclude_infos: true
          )

      summary = [
        "Summary:\n" <> Enum.map_join([summary1, summary2, summary3], "\n", &("  - " <> &1))
      ]

      assert_received {:mix_shell, :info, ^summary}
    end
  end

  describe "validate css" do
    test "no errors", %{opts: opts} do
      assert catch_exit(
               CLI.validate(
                 ["--server-url", Keyword.get(opts, :server_url), "test/fixtures/valid.css"],
                 :css
               )
             ) == {:shutdown, 0}

      assert_received {:mix_shell, :info, ["\nValidating CSS files:"]}
      assert_received {:mix_shell, :info, ["  - test/fixtures/valid.css\n"]}
      summary = [with_color("✓ All OK!", success_color())]
      assert_received {:mix_shell, :info, ^summary}
    end
  end

  describe "validate svg" do
    test "no errors", %{opts: opts} do
      assert catch_exit(
               CLI.validate(
                 ["--server-url", Keyword.get(opts, :server_url), "test/fixtures/valid.svg"],
                 :svg
               )
             ) == {:shutdown, 0}

      assert_received {:mix_shell, :info, ["\nValidating SVG files:"]}
      assert_received {:mix_shell, :info, ["  - test/fixtures/valid.svg\n"]}
      summary = [with_color("✓ All OK!", success_color())]
      assert_received {:mix_shell, :info, ^summary}
    end
  end
end
