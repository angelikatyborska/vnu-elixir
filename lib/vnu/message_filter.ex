defmodule Vnu.MessageFilter do
  @moduledoc """
  A behavior for excluding certain messages from the validation result.

  Modules implementing this behavior can be passed as a `:filter` option to:
  - `Vnu.validate_html/1`, `Vnu.validate_css/1`, `Vnu.validate_svg/1`
  - `Vnu.Assertions.assert_valid_html/1`, `Vnu.Assertions.assert_valid_css/1`. `Vnu.Assertions.assert_valid_svg/1`
  """

  @callback exclude_message?(Vnu.Message.t()) :: true | false
end
