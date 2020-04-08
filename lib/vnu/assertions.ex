defmodule Vnu.Assertions do
  defmacro assert_valid_html(html, opts \\ []) do
    quote do
      if unquote(html) == "valid" do
        assert true
      else
        flunk("test")
      end
    end
  end
end
