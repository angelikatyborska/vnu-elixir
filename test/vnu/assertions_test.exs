defmodule Vnu.AssertionsTest do
  use ExUnit.Case
  doctest Vnu.Assertions
  import Vnu.Assertions
  alias Vnu.{Formatter, Result}

  describe "assert_valid_html" do
    test "passes for valid html with only warnings" do
      html = """
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="utf-8">
          <title>Hello World</title>
        </head>
        </html>
      """

      return = assert_valid_html(html)
      assert return == html
    end

    test "fails for valid html with only warnings when fail_on_warnings true" do
      html = """
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>Hello World</title>
        </head>
        </html>
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_html(html)
      messages = Enum.filter(messages, &(&1.type == :error || &1.sub_type == :warning))

      try do
        assert_valid_html(html, fail_on_warnings: true)
        assert false
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the HTML document to be valid, but got 1 warning\n\n#{
                     Formatter.format_messages(messages)
                   }\n"
      end
    end

    test "fails when missing title" do
      html = """
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
      </head>
      </html>
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_html(html)
      errors = Enum.filter(messages, &(&1.type == :error))

      try do
        assert_valid_html(html)
        assert false
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the HTML document to be valid, but got 1 error\n\n#{
                     Formatter.format_messages(errors)
                   }\n"
      end
    end

    test "fails when many errors and many warnings" do
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

      {:ok, %Result{messages: messages}} = Vnu.validate_html(html)
      messages = Enum.filter(messages, &(&1.type == :error || &1.sub_type == :warning))

      try do
        assert_valid_html(html, fail_on_warnings: true)
        assert false
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the HTML document to be valid, but got 3 errors and 2 warnings\n\n#{
                     Formatter.format_messages(messages) |> Enum.join("\n\n")
                   }\n"
      end
    end
  end

  describe "assert_valid_css" do
    test "passes for valid css" do
      css = """
        nav { background-color: teal; }
        nav a { color: white; text-decoration: underline; }
      """

      return = assert_valid_css(css)
      assert return == css
    end

    test "fails when many errors and many warnings" do
      css = """
        nav { background-color: teal; }
        nav a { text-color: white; text-decoration: underline; }
        nav a:::hover { color: red }
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_css(css)
      messages = Enum.filter(messages, &(&1.type == :error || &1.sub_type == :warning))

      try do
        assert_valid_css(css, fail_on_warnings: true)
        assert false
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the CSS document to be valid, but got 2 errors\n\n#{
                     Formatter.format_messages(messages) |> Enum.join("\n\n")
                   }\n"
      end
    end
  end

  describe "assert_valid_svg" do
    test "passes for valid svg" do
      svg = """
      <svg width="5cm" height="4cm" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <desc>Rectangle</desc>
      <rect x="0.5cm" y="0.5cm" height="1cm" width="1cm"/>
      </svg>
      """

      return = assert_valid_svg(svg)
      assert return == svg
    end

    test "fails when many errors and many warnings" do
      svg = """
      <svg width="5cm" height="4cm" version="1.1" xmlns="http://www.w3.org/2000/svg">
      <desc>Rectangle</desc>
      <rect x="0.5cm" y="0.5cm" height="1cm"/>
      <rect x="3cm" y="5cm" width="1cm"/>
      <rect x="10cm" y="10cm" />
      </svg>
      """

      {:ok, %Result{messages: messages}} = Vnu.validate_svg(svg)
      messages = Enum.filter(messages, &(&1.type == :error || &1.sub_type == :warning))

      try do
        assert_valid_svg(svg, fail_on_warnings: true)
        assert false
      rescue
        error in [ExUnit.AssertionError] ->
          assert error.message ==
                   "Expected the SVG document to be valid, but got 4 errors\n\n#{
                     Formatter.format_messages(messages) |> Enum.join("\n\n")
                   }\n"
      end
    end
  end
end
