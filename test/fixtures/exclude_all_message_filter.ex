defmodule Vnu.ExcludeAllMessageFilter do
  @moduledoc false
  @behaviour Vnu.MessageFilter

  @impl Vnu.MessageFilter
  def exclude_message?(_), do: true
end
