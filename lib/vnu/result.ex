defmodule Vnu.Result do
  @moduledoc "A result holds a list of messages returned by the Checker for a given document."

  defstruct messages: []

  alias Vnu.Message

  @type t :: %__MODULE__{
          messages: list(Message.t())
        }
end
