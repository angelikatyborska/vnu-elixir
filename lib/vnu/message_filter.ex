defmodule Vnu.MessageFilter do
  @moduledoc """
  A behavior for excluding certain messages from the validation result.

  Modules implementing this behavior can be passed as a `:filter` option to:
  - `Vnu.validate_html/2`, `Vnu.validate_css/2`, `Vnu.validate_svg/2`
  - `Vnu.Assertions.assert_valid_html/2`, `Vnu.Assertions.assert_valid_css/2`. `Vnu.Assertions.assert_valid_svg/2`

  ## Example
  ```
  defmodule MyApp.VnuMessageFilter do
    @behaviour Vnu.MessageFilter

    @impl Vnu.MessageFilter
    def exclude_message?(%Vnu.Message{message: message}) do
      # those errors are caused by the CSRF meta tag (`csrf_meta_tag()`) present in the layout of a newly-generated Phoenix app
      patterns_to_ignore = [
        ~r/A document must not include more than one “meta” element with a “charset” attribute./,
        ~r/Attribute “(.)*” not allowed on element “meta” at this point./
      ]

      Enum.any?(patterns_to_ignore, &Regex.match?(&1, message))
    end
  end
  ```
  """

  @callback exclude_message?(Vnu.Message.t()) :: true | false
end
