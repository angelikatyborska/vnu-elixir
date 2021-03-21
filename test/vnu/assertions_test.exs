defmodule Vnu.AssertionsTest do
  use Vnu.ServerCase
  doctest Vnu.Assertions
  alias Vnu.{Formatter, Result}

  describe "assert_valid_html" do
    import Vnu.Assertions, only: [assert_valid_html: 2]

    test "passes for valid html with only warnings", %{opts: opts} do
      html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Hello World</title>
        </head>
        </html>
      """

      return = assert_valid_html(html, opts)
      assert return == html
    end

    test "fails for valid html with only warnings when fail_on_warnings true", %{opts: opts} do
      html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>Hello World</title>
        </head>
        </html>
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_html(html, opts)
      messages = Enum.filter(messages, &(&1.type == :error || &1.sub_type == :warning))

      try do
        assert_valid_html(html, Keyword.merge(opts, fail_on_warnings: true))
        raise "this line should not be reached"
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the HTML document to be valid, but got 1 warning\n\n#{
                     Formatter.format_messages(messages)
                   }\n"

        e ->
          reraise e, __STACKTRACE__
      end
    end

    test "fails when missing title", %{opts: opts} do
      html = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
      </head>
      </html>
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_html(html, opts)
      errors = Enum.filter(messages, &(&1.type == :error))

      try do
        assert_valid_html(html, opts)
        raise "this line should not be reached"
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the HTML document to be valid, but got 1 error\n\n#{
                     Formatter.format_messages(errors)
                   }\n"

        e ->
          reraise e, __STACKTRACE__
      end
    end

    test "passes if all errors were filtered out", %{opts: opts} do
      defmodule Filter do
        @behaviour Vnu.MessageFilter

        @impl Vnu.MessageFilter
        def exclude_message?(_), do: true
      end

      html = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
      </head>
      </html>
      """

      try do
        assert_valid_html(html, opts)
        raise "this line should not be reached"
      rescue
        _error in [ExUnit.AssertionError] ->
          assert_valid_html(html, Keyword.merge(opts, filter: Filter))

        e ->
          reraise e, __STACKTRACE__
      end
    end

    test "fails when many errors and many warnings with message_print_limit", %{opts: opts} do
      html = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <script type="text/javascript"></script>
      </head>
      <body>
        <p><div></div></p>
        </div>
      </body>
      </html>
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_html(html, opts)
      messages = Enum.filter(messages, &(&1.type == :error || &1.sub_type == :warning))

      try do
        assert_valid_html(
          html,
          Keyword.merge(opts, fail_on_warnings: true, message_print_limit: 3)
        )

        raise "this line should not be reached"
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the HTML document to be valid, but got 3 errors and 2 warnings\n\n#{
                     Enum.take(Formatter.format_messages(messages), 3) |> Enum.join("\n\n")
                   }\n\n...and 2 more.\n"

        e ->
          reraise e, __STACKTRACE__
      end
    end
  end

  describe "assert_valid_css" do
    import Vnu.Assertions, only: [assert_valid_css: 2]

    test "passes for valid css", %{opts: opts} do
      css = """
        nav { background-color: teal; }
        nav a { color: white; text-decoration: underline; }
      """

      return = assert_valid_css(css, opts)
      assert return == css
    end

    test "fails when many errors and many warnings", %{opts: opts} do
      css = """
        nav { background-color: teal; }
        nav a { text-color: white; text-decoration: underline; }
        nav a:::hover { color: red }
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_css(css, opts)
      messages = Enum.filter(messages, &(&1.type == :error || &1.sub_type == :warning))

      try do
        assert_valid_css(css, Keyword.merge(opts, fail_on_warnings: true))
        raise "this line should not be reached"
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the CSS document to be valid, but got 2 errors\n\n#{
                     Formatter.format_messages(messages) |> Enum.join("\n\n")
                   }\n"

        e ->
          reraise e, __STACKTRACE__
      end
    end
  end

  describe "assert_valid_svg" do
    import Vnu.Assertions, only: [assert_valid_svg: 2]

    test "passes for valid svg", %{opts: opts} do
      svg = """
      <svg width="5cm" height="4cm" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <desc>Rectangle</desc>
      <rect x="0.5cm" y="0.5cm" height="1cm" width="1cm"/>
      </svg>
      """

      return = assert_valid_svg(svg, opts)
      assert return == svg
    end

    test "fails when many errors and many warnings", %{opts: opts} do
      svg = """
      <svg width="5cm" height="4cm" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <desc>Rectangle</desc>
      <rect x="0.5cm" y="0.5cm" height="1cm"/>
      <rect x="3cm" y="5cm" width="1cm"/>
      <rect x="10cm" y="10cm" />
      </svg>
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_svg(svg, opts)
      messages = Enum.filter(messages, &(&1.type == :error || &1.sub_type == :warning))

      try do
        assert_valid_svg(svg, Keyword.merge(opts, fail_on_warnings: true))
        raise "this line should not be reached"
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the SVG document to be valid, but got 4 errors\n\n#{
                     Formatter.format_messages(messages) |> Enum.join("\n\n")
                   }\n"

        e ->
          reraise e, __STACKTRACE__
      end
    end
  end
end
